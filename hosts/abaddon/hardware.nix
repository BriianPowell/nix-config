{ config, lib, pkgs, modulesPath, ... }: {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b531c422-2edc-4913-b631-53308ce5efee";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/BE68-0A21";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/b33cbb9d-676d-458a-9fd3-612b9c80d152";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "nodiratime" "discard=async" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
