{ ... }: {
  boot = {
    loader = {
      # Use the grub2 EFI boot loader.
      grub = {
        enable = true;
        device = "nodev";
        version = 2;
        efiSupport = true;
        enableCryptodisk = true;
      };
      efi = {
        efiSysMountPoint = "/boot/efi";
        canTouchEfiVariables = true;
      };
    };

    initrd = {
      luks.devices."crypt-root" = {
        device = "/dev/disk/by-uuid/32155fc1-0d72-4cf5-a22b-280b8bf6896b"; # UUID for LUKS Disk Partion
        preLVM = true;
        keyFile = "/crypt-root-key.bin";
        allowDiscards = true;
      };
      secrets = {
        # Create /mnt/etc/secrets/initrd directory and copy keys to it
        "crypt-root-key.bin" = "/etc/secrets/initrd/crypt-root-key.bin";
      };

      # Enable SSH in initrd. Useful for unlocking LUKS remotely.
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyoha8WY7Pxd6THy+VbM4y+gvgrCUAx1RKAhDKMl+PE" ];
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
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
        # TODO: add a NIC module
      ];
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
  };
}