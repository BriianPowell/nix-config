# Machine / Homebrew overrides for boog's Mac(s).
#
# Host base lists live in hosts/<hostname>/brew.nix.
# Use omit* on a work machine, extra* for one-off apps.
#
{ ... }:
{
  machine = {
    username = "boog";

    homebrew = {
      extraTaps = [ ];
      extraBrews = [ ];
      extraCasks = [ ];
      extraMasApps = { };

      # Example (work laptop): omitCasks = [ "signal" "steam" ];
      omitBrews = [ ];
      omitCasks = [ ];
      omitMasApps = [ ];
    };
  };
}
