# Boot NVMe only (Crucial P5 1TB). The moriyya ZFS pool disks and the Micron
# cache NVMe are not described here and must not be: see ../disko-luks-lvm.nix.
import ../disko-luks-lvm.nix {
  device = "/dev/disk/by-id/nvme-CT1000P5PSSD8_2135313B98F0";
  # 140G home, the rest (~790G) for /.
  homeSize = "140G";
}
