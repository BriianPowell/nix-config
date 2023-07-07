{ config, lib, pkgs, modulesPath, ... }: {
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e0ebf86c-17ed-4d73-9d1c-c079e5d089b3";
    fsType = "ext4";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/C7D3-B98D";
    fsType = "vfat";
    options = [ "defaults" "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/8bed607d-fd79-4151-9a01-03d3bd9ec775";
    fsType = "btrfs";
    options = [ "defaults" "noatime" "nodiratime" "discard=async" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
