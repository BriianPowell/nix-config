{ pkgs, lib, dotfiles, ...}: {
  programs.fish = {
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "autopair.fish";
        src = pkgs.pkgs.fishPlugins.autopair-fish.src;
      }
      {
        name = "pbcopy";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-pbcopy";
          rev = "e8d78bb01f66246f7996a4012655b8ddbad777c2";
          hash = "sha256-B6/0tNk5lb+1nup1dfXhPD2S5PURZyFd8nJJF6shvq4=";
        };
      }
      {
        name = "node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "dudeofawesome";
          repo = "plugin-node-binpath";
          rev = "3d190054a4eb49b1cf656de4e3893ded33ce3023";
          hash = "8MQQ6LUBNgvUkgXu7ZWmfo2wRghCML4jXVxYUAXiwRc=";
        };
      }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          hash = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "fish-kubectl-aliases";
        src = pkgs.fetchFromGitHub {
          owner = "mibmo";
          repo = "fish-kubectl-aliases";
          rev = "29a3f686bbd7dc6d6cc5a7be6a50938f72845709";
          hash = "uzUkxjNCyP77El3s9pRBpn6nUudvN3+xQwRuolAQRyg=";
        };
      }
    ];
    shellInit = ". ~/.config/fish/config.fish";
  };

  xdg.configFile = {
    "fish/completions/et.fish".source = "${dotfiles}/home/.config/fish/completions/et.fish";
    "fish/config.fish".source = "${dotfiles}/home/.config/fish/config.fish";
    "fish/tide.config.fish".source = "${dotfiles}/home/.config/fish/tide.config.fish";
    "fish/kubectl_aliases.fish".source = "${dotfiles}/home/.config/fish/kubectl_aliases.fish";
    ".prettierrc.js".source = "${dotfiles}/home/.config/.prettierrc.js";
    "tmux/tmux.conf".source = "${dotfiles}/home/.config/tmux/tmux.conf";
  };

  # TODO: clone the dotfiles & server-admin-scripts repos
  home.file = {
    ".gemrc".source = "${dotfiles}/home/.gemrc";
    ".vim/vimrc".source = "${dotfiles}/home/.vim/vimrc";
    # ".local/bin/docker-logs".source = /home/boog/GitHub/server-admin-scripts/bin/docker-logs;
    # ".local/bin/docker-ps".source = /home/boog/GitHub/server-admin-scripts/bin/docker-ps;
    # ".local/bin/docker-top".source = /home/boog/GitHub/server-admin-scripts/bin/docker-top;
    # ".local/bin/lsdisk".source = /home/boog/GitHub/server-admin-scripts/bin/lsdisk;
  };
}
