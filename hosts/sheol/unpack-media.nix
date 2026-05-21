{ pkgs, ... }:

let
  downloadDir = "/mnt/moriyya/media/data/downloader/complete";

  unpackScript = pkgs.writeShellScript "unpack-media" ''
    set -euo pipefail

    DOWNLOAD_DIR="${downloadDir}"

    if [ ! -d "$DOWNLOAD_DIR" ]; then
      echo "Download directory $DOWNLOAD_DIR does not exist, skipping."
      exit 0
    fi

    echo "Scanning $DOWNLOAD_DIR for RAR archives..."

    find "$DOWNLOAD_DIR" -name '*.rar' -type f | while read -r rar_file; do
      dir="$(dirname "$rar_file")"
      echo "Extracting: $rar_file -> $dir"
      ${pkgs.unrar}/bin/unrar x -o- "$rar_file" "$dir/" || {
        echo "Failed to extract: $rar_file" >&2
      }
    done

    echo "Done."
  '';
in
{
  systemd.services.unpack-media = {
    description = "Extract RAR archives from media downloads";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = unpackScript;
      Nice = 19;
      IOSchedulingClass = "idle";
      RemainAfterExit = true;
    };
  };

  systemd.paths.unpack-media = {
    description = "Watch for new downloads to extract";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = downloadDir;
      MakeDirectory = true;
    };
  };
}
