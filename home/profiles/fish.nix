{ pkgs, lib, dotfiles, ... }:
{
  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "autopair.fish";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "fish-rbenv";
        src = pkgs.fetchFromGitHub {
          owner = "rbenv";
          repo = "fish-rbenv";
          rev = "209203428792db8c3084109b551d23e4e678fb17";
          sha256 = "1cksi1s8pm3r2171h68c5m2ip12j1niv8hhfcab5gjhm37fhvzsm";
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
        name = "node-binpath";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-node-binpath";
          rev = "70ecbe7be606b1b26bfd1a11e074bc92fe65550c";
          sha256 = "0zcl5jhq7n4b706hymhdg34dmag7b90214zqnbv5gxn22ivbsj8y";
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
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
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
        name = "fish-exa";
        src = pkgs.fetchFromGitHub {
          owner = "gazorby";
          repo = "fish-exa";
          rev = "92e5bcb762f7c08cc4484a2a09d6c176814ef35d";
          hash = "sha256-kw4XrchvF4SNNoX/6HRw2WPvCxKamwuTVWdHg82Pqac=";
        };
      }
    ] else [
      {
        name = "pbcopy";
        src = pkgs.fetchFromGitHub {
          owner = "oh-my-fish";
          repo = "plugin-pbcopy";
          rev = "e8d78bb01f66246f7996a4012655b8ddbad777c2";
          sha256 = "1bmy46mifjbjy9fj2rqiypj94g9ww7spaxgakssvz59rv6sg9bq7";
        };
      }
    ]);
    shellInit = ''. $HOME/.config/fish/config.fish'';
  };

  xdg.configFile = {
    "fish/completions/et.fish".source = "${dotfiles}/home/.config/fish/completions/et.fish";
    "fish/conf.d/eza_aliases.fish".source = "${dotfiles}/home/.config/fish/conf.d/eza_aliases.fish";
    "fish/conf.d/git_aliases.fish".source = "${dotfiles}/home/.config/fish/conf.d/git_aliases.fish";
    "fish/conf.d/kubectl_aliases.fish".source = "${dotfiles}/home/.config/fish/conf.d/kubectl_aliases.fish";
    "fish/functions/cl.fish".source = "${dotfiles}/home/.config/fish/functions/cl.fish";
    "fish/functions/git_current_branch.fish".source = "${dotfiles}/home/.config/fish/functions/git_current_branch.fish";
    "fish/functions/git_develop_branch.fish".source = "${dotfiles}/home/.config/fish/functions/git_develop_branch.fish";
    "fish/functions/git_feature_branch.fish".source = "${dotfiles}/home/.config/fish/functions/git_feature_branch.fish";
    "fish/functions/git_main_branch.fish".source = "${dotfiles}/home/.config/fish/functions/git_main_branch.fish";
    "fish/functions/gitclcd.fish".source = "${dotfiles}/home/.config/fish/functions/gitclcd.fish";
    "fish/functions/mkdir.fish".source = "${dotfiles}/home/.config/fish/functions/mkdir.fish";
    "fish/config.fish".source = lib.mkForce "${dotfiles}/home/.config/fish/config.fish";
    "fish/tide.config.fish".source = "${dotfiles}/home/.config/fish/tide.config.fish";
  };
}
