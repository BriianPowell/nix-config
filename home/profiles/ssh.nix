{
  dotfiles,
  pkgs,
  lib,
  ...
}:
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

  # darwin.config uses IdentityAgent ~/.1password/agent.sock (portable path).
  # 1Password's real socket lives elsewhere on macOS; link it at activation.
  home.activation = lib.optionalAttrs pkgs.stdenv.isDarwin {
    onepasswordAgentSymlink = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      link="$HOME/.1password/agent.sock"
      target=""

      # Link already points at a live socket
      if [ -L "$link" ]; then
        resolved=$(readlink "$link")
        case "$resolved" in
          /*) ;;
          *) resolved="$HOME/.1password/$resolved" ;;
        esac
        if [ -S "$resolved" ]; then
          exit 0
        fi
      fi

      # Known macOS location (1Password bundle id; same on all Macs today)
      mac_default="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      if [ -S "$mac_default" ]; then
        target="$mac_default"
      fi

      # Fallback if 1Password moves the socket under Group Containers
      if [ -z "$target" ] && [ -d "$HOME/Library/Group Containers" ]; then
        target=$(find "$HOME/Library/Group Containers" -path '*/t/agent.sock' -type s 2>/dev/null | head -n1 || true)
      fi

      if [ -z "$target" ]; then
        echo "warning: 1Password SSH agent socket not found; $link not updated" >&2
        exit 0
      fi

      run mkdir -p "$HOME/.1password"
      run ln -sfn "$target" "$link"
    '';
  };
}
