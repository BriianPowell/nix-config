{ config, pkgs, epkgs, lib, ... }:
{
  users.users.dudeofawesome = {
    description = "Louis Orleans";
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [ "wheel" "docker" ];
    passwordFile = "/etc/passwd-dudeofawesome";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMhI7UVBgKfEK7k2vjE51SBvmlL4tKp6Y54SoI8yDFX"
    ];
  };

  home-manager.users.dudeofawesome = {
    home.stateVersion = "21.11";

    programs.git = {
      enable = true;
      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";
    };

    programs.fish = {
      enable = true;
      plugins = [
        {
          name = "fisher";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "fisher";
            rev = "4.3.1";
            sha256 = "sha256-TR01V4Ol7zAj+3hvBj23PGSNjH+EHTcOQSKtA5uneGE";
          };
        }
        {
          name = "tide";
          src = pkgs.fetchFromGitHub {
            owner = "IlanCosman";
            repo = "tide";
            rev = "v5.3.0";
            sha256 = "sha256-B6/0tNk5lb+1nup1dfXhPD2S5PURZyFd8nJJF6shvq4=";
          };
        }
        {
          name = "pbcopy";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-pbcopy";
            rev = "e8d78bb01f66246f7996a4012655b8ddbad777c2";
            sha256 = "sha256-B6/0tNk5lb+1nup1dfXhPD2S5PURZyFd8nJJF6shvq4=";
          };
        }
        {
          name = "node-binpath";
          src = pkgs.fetchFromGitHub {
            owner = "dudeofawesome";
            repo = "plugin-node-binpath";
            rev = "3d190054a4eb49b1cf656de4e3893ded33ce3023";
            sha256 = "sha256-8MQQ6LUBNgvUkgXu7ZWmfo2wRghCML4jXVxYUAXiwRc=";
          };
        }
        {
          name = "autopair.fish";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "autopair.fish";
            rev = "1.0.3";
            sha256 = "sha256-l6WJ2kjDO/TnU9FSigjxk5xFp90xl68gDfggkE/wrlM=";
          };
        }
        {
          name = "nix-env.fish";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
          };
        }
      ];
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

    imports = [
      # ../pkgs/dotfiles.nix
    ];

    # home.file = {
    #   ".config/xorg".source = ./config/xorg;
    #   ".config/zsh".source = ./config/zsh;
    #   ".config/nvim".source = ./config/nvim;
    #   ".config/qutebrowser".source = ./config/qutebrowser;
    #   ".config/sxiv".source = ./config/sxiv;
    #   ".local/share/qutebrowser/userscripts".source = ./config/qutebrowser/userscripts;
    #   ".local/share/qutebrowser/greasemonkey".source = ./config/qutebrowser/greasemonkey;
    #   # ".local/share/qutebrowser/sessions".source = ./private-config/qutebrowser/sessions;
    #   ".config/dunst".source = ./config/dunst;
    #   ".config/lf".source = ./config/lf;
    #   ".config/picom.conf".source = ./config/picom.conf;
    #   ".wyrdrc".source = ./config/remind/.wyrdrc;
    #   "scripts".source = ./scripts;
    # };
  };
}
