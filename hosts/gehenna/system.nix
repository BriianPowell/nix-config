{ lib, ... }: {
  networking.hostName = "gehenna";

  # WSL handles DNS / interfaces via /etc/wsl.conf and the Windows host; we
  # only need the firewall disabled so the Windows-side networking can reach in.
  networking.firewall.enable = lib.mkDefault false;

  system.stateVersion = "24.11";
  time.timeZone = lib.mkDefault "America/Los_Angeles";

  services.vscode-server.enable = true;

  # WSL disks live on a sparse VHDX that doesn't reclaim on its own; keep the
  # store from ballooning by garbage-collecting older generations weekly.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
}
