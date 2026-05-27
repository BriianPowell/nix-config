# Atuin shell history (wraps programs.atuin).
#
# Per user: atuin.enable = true;
# Overrides: atuin.settings = { ... };
#
{ config, lib, pkgs, ... }:
let
  cfg = config.atuin;
in
{
  options.atuin = {
    enable = lib.mkEnableOption "atuin shell history";

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = ''
        Merged into programs.atuin.settings (written to config.toml).
        Module defaults apply first; user settings override.
      '';
    };

    enableFishIntegration = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Bind fish up-arrow to atuin (requires fish.enable).";
    };

    forceOverwriteSettings = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Overwrite existing config.toml. Recommended: atuin rewrites this file on use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      inherit (cfg) forceOverwriteSettings;
      enableFishIntegration = cfg.enableFishIntegration && config.fish.enable;

      settings = {
        sync_address = "https://atuin.powell.place";
        enter_accept = true;
        sync.records = true;
      }
      // cfg.settings;
    };
  };
}
