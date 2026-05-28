# Home Manager module: declarative git (wraps programs.git).
#
# Per user:
#   git = {
#     enable = true;
#     userName = "...";
#     userEmail = "...";
#   };
#
# Shared defaults (editor, rebase, GitHub SSH URL) live here; identity in users/*/git.nix.
#
{ config, lib, pkgs, ... }:
let
  cfg = config.git;
in
{
  options.git = {
    enable = lib.mkEnableOption "git configuration";

    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git user.name";
    };

    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user.email";
    };

    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Extra keys merged into programs.git.settings";
    };

    ignores = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Global ignore patterns (programs.git.ignores)";
    };

    signing = {
      enable = lib.mkEnableOption "SSH commit signing";

      key = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "SSH public key for user.signingKey";
      };

      signer = lib.mkOption {
        type = lib.types.str;
        default = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        description = "Path to op-ssh-sign or other SSH signer";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      settings = {
        user.name = cfg.userName;
        user.email = cfg.userEmail;
        core.editor = "vim";
        pull.rebase = true;
        url."ssh://git@github.com/".insteadOf = "https://github.com/";
      }
      // lib.optionalAttrs (cfg.ignores != [ ]) {
        core.excludesFile = "${config.xdg.configHome}/git/ignore";
      }
      // cfg.settings;

      signing = lib.mkIf cfg.signing.enable {
        key = cfg.signing.key;
        format = "ssh";
        signByDefault = true;
        signer = cfg.signing.signer;
      };
    };

    # Managed here (not programs.git.ignores) so text + force are defined together.
    xdg.configFile."git/ignore" = lib.mkIf (cfg.ignores != [ ]) {
      text = lib.concatStringsSep "\n" cfg.ignores + "\n";
      force = true;
    };
  };
}
