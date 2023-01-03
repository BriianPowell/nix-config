{ config, pkgs, epkgs, lib, ... }:
{
  users.users.boog = {
    description = "Brian Powell";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" ];
    passwordFile = "/etc/passwd-boog";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKXvyAnsaJWov91AOHE+dzxKNXbBOSDWBnDEHa13gex"
    ];
  };

  home-manager.users.boog = {
    home.stateVersion = "22.11";

    programs.git = {
      enable = true;
      userName = "Brian Powell";
      userEmail = "brian@powell.place";
    };

    programs.fish = {
      enable = true;
      plugins = [
        # {
        #   name = "fisher";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "jorgebucaran";
        #     repo = "fisher";
        #     rev = "4.3.1";
        #     sha256 = "sha256-TR01V4Ol7zAj+3hvBj23PGSNjH+EHTcOQSKtA5uneGE";
        #   };
        # }
        {
          name = "tide";
          src = pkgs.fetchFromGitHub {
            owner = "IlanCosman";
            repo = "tide";
            rev = "6833806ba2eaa1a2d72a5015f59c284f06c1d2db";
            sha256 = "vi4sYoI366FkIonXDlf/eE2Pyjq7E/kOKBrQS+LtE+M=";
          };
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
          name = "autopair.fish";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "autopair.fish";
            rev = "244bb1ebf74bf944a1ba1338fc1026075003c5e3";
            sha256 = "s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
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
      ];
      shellInit = ". ~/.config/fish/dotfiles-config.fish";
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
      ".config/fish/dotfiles-config.fish".source = /home/boog/GitHub/dotfiles/home/.config/fish/config.fish;
      ".config/fish/tide.config.fish".source = /home/boog/GitHub/dotfiles/home/.config/fish/tide.config.fish;
      ".config/tmux/tmux.conf".source = /home/boog/GitHub/dotfiles/home/.config/tmux/tmux.conf;
      ".config/.prettierrc".source = /home/boog/GitHub/dotfiles/home/.config/.prettierrc;

      ".local/bin/docker-logs".source = /home/boog/GitHub/server-admin-scripts/bin/docker-logs;
      ".local/bin/docker-ps".source = /home/boog/GitHub/server-admin-scripts/bin/docker-ps;
      ".local/bin/docker-top".source = /home/boog/GitHub/server-admin-scripts/bin/docker-top;
      ".local/bin/lsdisk".source = /home/boog/GitHub/server-admin-scripts/bin/lsdisk;
    };
  };
}
