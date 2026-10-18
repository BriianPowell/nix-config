{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4718d5fc-375a-4eb6-8fde-726e245fea0e";
    fsType = "ext4";
    options = [
      "defaults"
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/F872-FED1";
    fsType = "vfat";
    options = [
      "defaults"
      "noatime"
      "nodiratime"
      "discard"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/cb4ee535-0418-4cbb-a65f-25671a4d90a9";
    fsType = "btrfs";
    options = [
      "defaults"
      "noatime"
      "nodiratime"
      "discard=async"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
