{ config, ... }:

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

  # Enable SSH in initrd. Useful for unlocking LUKS remotely.
  boot.initrd.network.enable = true;
  boot.initrd.network.ssh = {
    enable = true;
    port = 22;
    authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMhI7UVBgKfEK7k2vjE51SBvmlL4tKp6Y54SoI8yDFX" ];
    hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
  };
  boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
    # TODO: add a NIC module
  ];
}
