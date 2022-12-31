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
      device = "/dev/disk/by-id/dm-uuid-CRYPT-LUKS1-537a87db147b4e8eba7727072781757b-crypt-root"; # UUID for LUKS vol
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
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILZqx63pRUSW71y5q6m8Uruo2+dcj7IAMGDvN24mq7yL" ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      # TODO: add a NIC module
    ];
  };
}
