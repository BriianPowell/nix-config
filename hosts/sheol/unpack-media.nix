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
      # Each archive is extracted once. Without this, a release whose video was
      # moved away after import (Sonarr/Radarr) would be extracted again on every
      # run, because `unrar -o-` only skips files that still exist.
      marker="$rar_file.unpacked"
      if [ -e "$marker" ]; then
        continue
      fi

      dir="$(dirname "$rar_file")"
      echo "Extracting: $rar_file -> $dir"

      rc=0
      ${pkgs.unrar}/bin/unrar x -o- "$rar_file" "$dir/" || rc=$?

      # 10 is "No files to extract": everything is already on disk, so it counts as
      # done. Any other failure (e.g. a missing volume in an incomplete set) leaves
      # no marker, so the archive is retried on the next run.
      case "$rc" in
        0|10) touch "$marker" ;;
        *) echo "Failed to extract (unrar exit $rc): $rar_file" >&2 ;;
      esac
    done

    echo "Done."
  '';
in
{
  systemd.services.unpack-media = {
    description = "Extract RAR archives from media downloads";
    wantedBy = [ "multi-user.target" ];
    # The path unit below can trigger this many times in a short burst. Without
    # this, systemd's start limit marks the service failed, and the path unit
    # then fails with it and stops watching.
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig = {
      Type = "oneshot";
      # Same owner as the media apps (media-user.nix), so extracted files are not root-owned and
      # Sonarr/Radarr (PUID 1500) can import and delete them. Needs the download tree to be owned
      # by this user first.
      User = "media";
      Group = "media";
      ExecStart = unpackScript;
      Nice = 19;
      IOSchedulingClass = "idle";
      # No RemainAfterExit: it kept the service "active (exited)" after the boot
      # run, so the path unit's later triggers were no-ops and nothing was
      # extracted until the next reboot.
    };
  };

  # Backstop for the path unit below: it drops any change that happens while the
  # service is already running, so that release would otherwise wait until the
  # next boot. Cheap, because archives with a marker are skipped.
  systemd.timers.unpack-media = {
    description = "Periodically extract RAR archives the path unit may have missed";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Counts from when the last run finished, so runs never overlap or queue up.
      OnUnitInactiveSec = "45min";
      # Covers the case where the service has not run yet since this timer started.
      OnBootSec = "45min";
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
