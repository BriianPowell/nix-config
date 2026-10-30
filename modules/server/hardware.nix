{
  config,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.server.disks;
  # noatime implies nodiratime. TRIM runs from fstrim.timer rather than a
  # continuous `discard` mount option.
  opts = [ "noatime" ];
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  options.server.disks = {
    root = lib.mkOption {
      type = lib.types.str;
      description = "UUID of the ext4 root filesystem (the unlocked LUKS volume).";
    };
    efi = lib.mkOption {
      type = lib.types.str;
      description = "UUID of the vfat EFI system partition (mounted at /boot/efi).";
    };
    home = lib.mkOption {
      type = lib.types.str;
      description = "UUID of the btrfs /home filesystem.";
    };
  };

  config = {
    # mkDefault so a disko layout (the <host>-install configurations) can take over
    # the mounts; a host that does not use disko gets exactly these.
    fileSystems."/" = {
      device = lib.mkDefault "/dev/disk/by-uuid/${cfg.root}";
      fsType = lib.mkDefault "ext4";
      options = opts;
    };

    fileSystems."/boot/efi" = {
      device = lib.mkDefault "/dev/disk/by-uuid/${cfg.efi}";
      fsType = lib.mkDefault "vfat";
      options = opts;
    };

    fileSystems."/home" = {
      device = lib.mkDefault "/dev/disk/by-uuid/${cfg.home}";
      fsType = lib.mkDefault "btrfs";
      options = opts;
    };

    services.fstrim.enable = true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
