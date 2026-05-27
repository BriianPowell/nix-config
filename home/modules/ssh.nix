# SSH client config and 1Password agent socket symlink (macOS).
#
# Per user: ssh.enable = true;
#
{ config, lib, pkgs, ... }:
let
  cfg = config.ssh;
  sshDir = ../ssh;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  onePasswordAgentSocket =
    "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  options.ssh = {
    enable = lib.mkEnableOption "SSH client configuration";
  };

  config = lib.mkIf cfg.enable {
    home.file.".ssh/config".source =
      if isDarwin then "${sshDir}/darwin.config" else "${sshDir}/default.config";

    home.activation = lib.optionalAttrs isDarwin {
      onepasswordAgentSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.1password"
        run ln -sfn "${onePasswordAgentSocket}" "$HOME/.1password/agent.sock"
      '';
    };
  };
}
