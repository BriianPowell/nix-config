# Machine-level options for nix-darwin hosts (boog-MBP and future Macs).
#
# Values are set in users/darwin/machine.nix (or per-host users/<name>/machine.nix).
#
{ lib, ... }:
{
  options.machine = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "boog";
      description = ''
        Primary macOS account name. Must match:
        - system.primaryUser
        - users.users.<name>
        - home-manager.users.<name>
        - home directory /Users/<name>
      '';
    };

    homebrew = {
      extraTaps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional Homebrew taps.";
      };

      extraBrews = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional Homebrew formulae.";
      };

      extraCasks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Additional Homebrew casks.";
      };

      extraMasApps = lib.mkOption {
        type = lib.types.attrsOf lib.types.int;
        default = { };
        description = "Additional Mac App Store apps (name = app ID).";
      };

      omitBrews = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Formulae to remove from the host base list.";
      };

      omitCasks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = ''
          Casks to remove from the host base list (e.g. blocked on a work laptop).
        '';
      };

      omitMasApps = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Mac App Store app names to remove from the host base list.";
      };
    };
  };
}
