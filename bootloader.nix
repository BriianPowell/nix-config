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
      device = "/dev/disk/by-uuid/425ba9df-a7ac-454e-9c25-efeaa86e75b2"; # UUID for LUKS vol
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
      authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMhI7UVBgKfEK7k2vjE51SBvmlL4tKp6Y54SoI8yDFX" ];
      hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    };
    availableKernelModules = [
      "aesni_intel"
      "cryptd"
      # TODO: add a NIC module
    ];
  };
}
