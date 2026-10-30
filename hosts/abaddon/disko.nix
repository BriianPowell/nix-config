# Only disk in the machine (SK hynix 128GB SATA SSD).
import ../disko-luks-lvm.nix {
  device = "/dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MI81N035211101A0U";
  # 18G home, the rest (~100G) for /.
  homeSize = "18G";
}
