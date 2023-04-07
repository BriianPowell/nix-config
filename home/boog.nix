{ config, pkgs, lib, ... }:
{
  home.stateVersion = "22.11";

  programs.git = {
    enable = true;
    userName = "Brian Powell";
    userEmail = "brian@powell.place";
  };

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
          sha256 = "B6/0tNk5lb+1nup1dfXhPD2S5PURZyFd8nJJF6shvq4=";
        };
      }
      {
        name = "node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "dudeofawesome";
          repo = "plugin-node-binpath";
          rev = "3d190054a4eb49b1cf656de4e3893ded33ce3023";
          sha256 = "8MQQ6LUBNgvUkgXu7ZWmfo2wRghCML4jXVxYUAXiwRc=";
        };
      }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
      {
        name = "fish-kubectl-aliases";
        src = pkgs.fetchFromGitHub {
          owner = "mibmo";
          repo = "fish-kubectl-aliases";
          rev = "29a3f686bbd7dc6d6cc5a7be6a50938f72845709";
          sha256 = "uzUkxjNCyP77El3s9pRBpn6nUudvN3+xQwRuolAQRyg=";
        };
      }
    ];
    shellInit = ". ~/.config/fish/config.fish";
  };

  xdg.configFile."fish/conf.d/plugin-tide.fish".text = lib.mkAfter ''
    for f in $plugin_dir/*.fish
      source $f
    end
  '';

  programs.vim = {
    enable = true;
    # defaultEditor = true;
    plugins = with pkgs.vimPlugins; [
      nerdtree
      papercolor-theme
      rainbow_parentheses
      vim-airline
      vim-prettier
    ];
  };

  # TODO: clone the dotfiles & server-admin-scripts repos
  home.file = {
    # TODO: figure out how to make this more flexible in the source path
    ".gemrc".source = /home/boog/GitHub/dotfiles/home/.gemrc;
    ".vim/vimrc".source = /home/boog/GitHub/dotfiles/home/.vim/vimrc;
    ".config/fish/completions/et.fish".source = /home/boog/GitHub/dotfiles/home/.config/fish/completions/et.fish;
    ".config/fish/config.fish".source = /home/boog/GitHub/dotfiles/home/.config/fish/config.fish;
    ".config/fish/tide.config.fish".source = /home/boog/GitHub/dotfiles/home/.config/fish/tide.config.fish;
    ".config/tmux/tmux.conf".source = /home/boog/GitHub/dotfiles/home/.config/tmux/tmux.conf;
    ".config/.prettierrc".source = /home/boog/GitHub/dotfiles/home/.config/.prettierrc;

    ".local/bin/docker-logs".source = /home/boog/GitHub/server-admin-scripts/bin/docker-logs;
    ".local/bin/docker-ps".source = /home/boog/GitHub/server-admin-scripts/bin/docker-ps;
    ".local/bin/docker-top".source = /home/boog/GitHub/server-admin-scripts/bin/docker-top;
    ".local/bin/lsdisk".source = /home/boog/GitHub/server-admin-scripts/bin/lsdisk;
  };
}
