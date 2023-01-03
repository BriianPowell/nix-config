{ config, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;

  # Use the grub2 EFI boot loader.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
  };

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [
    "r8169"
    "e1000e"
    "br_netfilter"
    "overlay"
  ];

  boot.initrd = {
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
    network.enable = true;
    network.ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICyoha8WY7Pxd6THy+VbM4y+gvgrCUAx1RKAhDKMl+PE" ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      # TODO: add a NIC module
    ];
    kernelModules = [
      "r8169"
      "e1000e"
    ];
  };
}
