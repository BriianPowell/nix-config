# Shared disko layout for the k3s nodes (sheol, abaddon). The same shape as the
# manual install in docs/INSTALL.md:
#
#   GPT: ESP (/boot/efi) + LUKS "root" -> LVM vg { root: ext4 /, home: btrfs /home }
#
# Differences from that guide: LUKS2 (the default; the guide's LUKS1 was for GRUB,
# but these hosts boot with systemd-boot and a systemd initrd) and no key file in
# the initrd (boot.nix does not use one). Mount options come from
# modules/server/hardware.nix (noatime; TRIM is fstrim.timer), so none are set here.
#
# This is for (re)installing only. It is used by the `<host>-install` entries in
# nixosConfigurations (flake.nix), not by the running hosts, which keep their
# UUID-based fileSystems in hardware.nix.
#
# Running disko in a format mode WIPES `device`. Only the boot disk is described
# here; sheol's `moriyya` ZFS pool disks are intentionally left out.
#
# The LUKS passphrase is read from /tmp/luks-passphrase on the machine being
# installed (nixos-anywhere --disk-encryption-keys puts it there), so no secret
# lives in git. The file is only used to format; unlocking at boot is still the
# remote SSH prompt. boot.nix names the mapping "root", hence the LUKS name below.
{ device, homeSize }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      inherit device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot/efi";
              extraArgs = [
                "-n"
                "boot"
              ];
            };
          };

          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "root";
              passwordFile = "/tmp/luks-passphrase";
              content = {
                type = "lvm_pv";
                vg = "vg";
              };
            };
          };
        };
      };
    };

    lvm_vg.vg = {
      type = "lvm_vg";
      lvs = {
        # `home` has a fixed size and `root` takes whatever is left. LVs are created
        # in name order, so the fixed one is carved out first.
        home = {
          size = homeSize;
          content = {
            type = "filesystem";
            format = "btrfs";
            mountpoint = "/home";
            extraArgs = [
              "-L"
              "home"
            ];
          };
        };

        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
            extraArgs = [
              "-L"
              "root"
            ];
          };
        };
      };
    };
  };
}
