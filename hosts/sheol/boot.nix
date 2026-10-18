{ config, lib, ... }: {
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

    kernelModules = [
      "kvm-intel"
      "r8169"
      "e1000e"
      "br_netfilter"
      "overlay"
      "ip_vs"
      "ip_vs_rr"
      "ip_vs_wrr"
      "ip_vs_sh"
      "nf_conntrack"
    ];
    extraModulePackages = [ ];
    kernel.sysctl = {
      "net.bridge-nf-call-ip6tables" = 1;
      "net.bridge-nf-call-iptables" = 1;
      "net.ipv4.ip_forward" = 1; # enable for k3s
      "net.ipv6.conf.all.forwarding" = 1; # enable for k3s
      "fs.inotify.max_user_instances" = 8192; # Fix for 'Too many open files error'
      "fs.inotify.max_user_watches" = 524288; # Fix for 'Too many open files error'
      # https://docs.k3s.io/security/hardening-guide#ensure-protect-kernel-defaults-is-set
      "vm.panic_on_oom" = 0;
      "vm.overcommit_memory" = 1;
      "kernel.panic" = 10;
      "kernel.panic_on_oops" = 1;
    };

    #
    # Remote LUKS unlock over SSH, using the systemd stage 1 initrd (the default
    # since 26.05; the scripted initrd is removed in 26.11). Unlock with:
    #   ssh -o RequestTTY=force abaddonInitrd
    # The forced `systemctl default` waits for the root device, and systemctl
    # starts the password agent, which prompts for the passphrase.
    # Based on:
    # https://nixos.wiki/wiki/Remote_LUKS_Unlocking
    #
    initrd = {
      # DHCP comes from networking.interfaces.<nic>.useDHCP, which the initrd reuses.
      systemd.enable = true;

      luks.devices.root.device = "/dev/disk/by-uuid/32155fc1-0d72-4cf5-a22b-280b8bf6896b";

      network = {
        enable = true;

        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [
            "/etc/secrets/initrd/ssh_host_rsa_key"
            "/etc/secrets/initrd/ssh_host_ed25519_key"
          ];
          authorizedKeys = [
            ''command="systemctl default",no-port-forwarding,no-agent-forwarding,no-X11-forwarding ${(import ../../secrets/keys.nix).nixosAdmin}''
          ];
        };
      };

      kernelModules = [
        "r8169"
        "e1000e"
        "dm-snapshot"
      ];

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
}
