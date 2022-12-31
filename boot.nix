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

  boot.initrd = {
    luks.devices."crypt-root" = {
      device = "/dev/disk/by-uuid/2fb0126c-3434-4d3c-a9a7-58277566dd4a"; # UUID for LUKS Root Volume
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
      port = 22;
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILtyDFLTmU2WK5rsx7Hxd1X7Y2wCxanbTb3rIrGcyHzb" ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      # TODO: add a NIC module
    ];
  };
}
