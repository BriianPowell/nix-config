{ config, pkgs, epkgs, lib, ... }:
{
  home-manager.users.louis = {
    home.stateVersion = "22.11";

    programs.git = {
      enable = true;
      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";
    };

    programs.fish = {
      plugins = [
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
    };

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
  };
}
