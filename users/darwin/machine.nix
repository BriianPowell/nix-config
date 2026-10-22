# Machine / Homebrew overrides for boog's Mac(s).
#
# This folder is called `darwin` rather than after the person on purpose: the Mac
# account name (`machine.username` below) is fixed by the machine and does not match
# the `boog` used on the servers, so the folder is named for the platform instead.
# The account name is written once, here.
#
# Host base lists live in hosts/<hostname>/brew.nix.
# Use omit* on a work machine, extra* for one-off apps.
#
_: {
  machine = {
    username = "Brian_Powell";

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
