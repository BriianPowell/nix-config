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
      "net.ipv6.conf.all.forwarding" = 1; #enable for k3s
      "fs.inotify.max_user_instances" = 8192; # Fix for 'Too many open files error'
      "fs.inotify.max_user_watches" = 524288; # Fix for 'Too many open files error'
    };

    #
    # Utilizing:
    # https://mth.st/blog/nixos-initrd-ssh/
    #
    initrd = {
      preLVMCommands = lib.mkOrder 400 "sleep 1";
      luks = {
        forceLuksSupportInInitrd = true;
      };

      # Enable SSH in initrd. Useful for unlocking LUKS remotely.
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];
          authorizedKeys = config.users.users.boog.openssh.authorizedKeys.keys;
        };
        postCommands =
          let
            disk = "/dev/disk/by-uuid/32155fc1-0d72-4cf5-a22b-280b8bf6896b";
          in
          ''
            echo 'cryptsetup luksOpen ${disk} root && echo > /tmp/continue' >> /root/.profile
            echo 'starting sshd...'
          '';
      };

      # Block the boot process until /tmp/continue is written to
      postDeviceCommands = ''
        echo 'waiting for root device to be opened...'
        mkfifo /tmp/continue
        cat /tmp/continue
      '';

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
        # TODO: add a NIC module
      ];
    };
  };
}
