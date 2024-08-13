{ dotfiles, ... }: {

  home.file = {
    ".editorconfig".source = "${dotfiles}/home/.editorconfig";
    ".finicky.js".source = "${dotfiles}/home/.finicky.js";
    ".gemrc".source = "${dotfiles}/home/.gemrc";
    ".prettierrc.js".source = "${dotfiles}/home/.prettierrc.js";
  };

  xdg.configFile = {
    "tmux/tmux.conf".source = "${dotfiles}/home/.config/tmux/tmux.conf";
    "1Password/ssh/agent.toml".source = "${dotfiles}/home/.config/1Password/ssh/agent.toml";
  };
}
