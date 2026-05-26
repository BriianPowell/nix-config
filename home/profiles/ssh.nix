{ dotfiles, pkgs, lib, ... }:
let
  onePasswordAgentSocket =
    "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
in
{
  home.file =
    if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then
      {
        ".ssh/config".source = "${dotfiles}/home/.ssh/darwin.config";
      }
    else
      {
        ".ssh/config".source = "${dotfiles}/home/.ssh/default.config";
      };

  home.activation =
    lib.optionalAttrs pkgs.stdenv.isDarwin {
      # Symlink so IdentityAgent ~/.1password/agent.sock resolves (see dotfiles agent.toml)
      onepasswordAgentSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/.1password"
        run ln -sfn "${onePasswordAgentSocket}" "$HOME/.1password/agent.sock"
      '';
    };
}
