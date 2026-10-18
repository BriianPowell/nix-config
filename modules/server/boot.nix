{ config, lib, ... }:
let
  cfg = config.server;
in
{
  options.server.luksUuid = lib.mkOption {
    type = lib.types.str;
    description = "UUID of the LUKS container holding the root filesystem (unlocked remotely over SSH in the initrd).";
  };

  options.server.nicDrivers = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "Kernel modules for the NICs, loaded in the initrd so remote LUKS unlock has networking.";
  };

  config = {
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          configurationLimit = 10;
          editor = false;
        };
        efi = {
          efiSysMountPoint = "/boot/efi";
          canTouchEfiVariables = true;
        };
      };

      # What k3s needs beyond the defaults; NIC drivers load via udev.
      kernelModules = [
        "br_netfilter"
        "overlay"
        "nf_conntrack"
      ];
      kernel.sysctl = {
        "net.bridge-nf-call-ip6tables" = 1;
        "net.bridge-nf-call-iptables" = 1;
        "net.ipv4.ip_forward" = 1; # enable for k3s
        "net.ipv6.conf.all.forwarding" = 1; # enable for k3s
        "fs.inotify.max_user_instances" = 8192; # Fix for 'Too many open files error'
        "fs.inotify.max_user_watches" = 524288; # Fix for 'Too many open files error'
      };

      #
      # Remote LUKS unlock over SSH, using the systemd stage 1 initrd (the default
      # since 26.05; the scripted initrd is removed in 26.11). Unlock with:
      #   ssh -o RequestTTY=force <host>Initrd
      # The forced `systemctl default` waits for the root device, and systemctl
      # starts the password agent, which prompts for the passphrase.
      # DHCP comes from networking.interfaces.<nic>.useDHCP, which the initrd reuses.
      # Based on:
      # https://nixos.wiki/wiki/Remote_LUKS_Unlocking
      #
      initrd = {
        systemd.enable = true;

        luks.devices.root.device = "/dev/disk/by-uuid/${cfg.luksUuid}";

        network = {
          enable = true;
          ssh = {
            enable = true;
            port = 2222;
            hostKeys = [
              "/etc/secrets/initrd/ssh_host_rsa_key"
              "/etc/secrets/initrd/ssh_host_ed25519_key"
            ];
            authorizedKeys = map (
              key: ''command="systemctl default",no-port-forwarding,no-agent-forwarding,no-X11-forwarding ${key}''
            ) config.site.initrdAuthorizedKeys;
          };
        };

        kernelModules = cfg.nicDrivers;

        availableKernelModules = [
          "aesni_intel"
          "cryptd"
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
      };
    };

    # The root device only appears once the LUKS passphrase is entered. systemd's
    # default 90s device timeout would drop a slow remote unlock into emergency mode.
    fileSystems."/".options = [ "x-systemd.device-timeout=infinity" ];
  };
}
