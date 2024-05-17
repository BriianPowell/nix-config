{ pkgs, lib, dotfiles, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "pbcopy";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-pbcopy";
          rev = "e8d78bb01f66246f7996a4012655b8ddbad777c2";
          sha256 = "1bmy46mifjbjy9fj2rqiypj94g9ww7spaxgakssvz59rv6sg9bq7";
        };
      }
      {
        name = "node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "dudeofawesome";
          repo = "plugin-node-binpath";
          rev = "3d190054a4eb49b1cf656de4e3893ded33ce3023";
          sha256 = "05y1w82m0n2wblivwc22113b13bylsayvvh5jba0ndh1npl11i7h";
        };
      }
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
        };
      }
      {
        name = "plugin-rbenv";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-rbenv";
          rev = "e879897d0cb09667f14b48901446b31d10a21b1b";
          sha256 = "0ypm6fk3i5fqdxsz2ja85pg7qxihzck8vhinfdln9jdi05l49a6i";
        };
      }
      {
        name = "fish-kubectl-aliases";
        src = pkgs.fetchFromGitHub {
          owner = "mibmo";
          repo = "fish-kubectl-aliases";
          rev = "29a3f686bbd7dc6d6cc5a7be6a50938f72845709";
          sha256 = "0a27218a4vh48fqpydvgwx9afzm686agdv2x2bxzxj226g328ddv";
        };
      }
    ]
    ++ (if pkgs.system == "aarch64-darwin" then [
      {
        name = "plugin-osx";
        src = pkgs.fetchFromGitHub
          {
            owner = "oh-my-fish";
            repo = "plugin-osx";
            rev = "27039b251201ec2e70d8e8052cbc59fa0ac3b3cd";
            sha256 = "032yfxz10vypywfivggsam77b8zplmgafbc0gqks8cxhfy9hh9cd";
          };
      }
      {
        name = "nvm.fish";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "nvm.fish";
          rev = "c69e5d1017b21bcfca8f42c93c7e89fff6141a8a";
          sha256 = "084wvdinas1d7v3da16lim7s8asimh389frmfamr7q70fy44spid";
        };
      }
    ] else [ ]);
    shellInit = ''. ~/.config/fish/config.fish'';
  };

  xdg.configFile = {
    "fish/completions/et.fish".source = "${dotfiles}/home/.config/fish/completions/et.fish";
    "fish/functions/.kubectl_aliases.fish".source = "${dotfiles}/home/.config/fish/functions/.kubectl_aliases.fish";
    "fish/config.fish".source = lib.mkForce "${dotfiles}/home/.config/fish/config.fish";
    "fish/tide.config.fish".source = "${dotfiles}/home/.config/fish/tide.config.fish";
    "fish/kubectl_aliases.fish".source = "${dotfiles}/home/.config/fish/kubectl_aliases.fish";
    "tmux/tmux.conf".source = "${dotfiles}/home/.config/tmux/tmux.conf";
  };

  home.file = {
    ".editorconfig".source = "${dotfiles}/home/.editorconfig";
    ".finicky.js".source = "${dotfiles}/home/.finicky.js";
    ".gemrc".source = "${dotfiles}/home/.gemrc";
    ".prettierrc.js".source = "${dotfiles}/home/.prettierrc.js";
  };
}
