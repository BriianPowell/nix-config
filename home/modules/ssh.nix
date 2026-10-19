# SSH client config and 1Password agent socket symlink (macOS).
#
# Per user: ssh.enable = true; ssh.configFile = ./ssh.config;
#
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ssh;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  onePasswordAgentSocket = "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  options.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File installed as ~/.ssh/config. Hosts and identities are personal, so each user supplies their own.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".ssh/config" = lib.mkIf (cfg.configFile != null) { source = cfg.configFile; };

    home.activation = lib.optionalAttrs isDarwin {
      onepasswordAgentSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.1password"
        run ln -sfn "${onePasswordAgentSocket}" "$HOME/.1password/agent.sock"
      '';
    };
  };
}
