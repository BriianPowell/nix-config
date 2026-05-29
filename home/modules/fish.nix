# Fish shell: plugins, tide, aliases, functions (files under home/fish/).
#
# Per user: fish.enable = true;
#
{ config, lib, pkgs, ... }:
let
  cfg = config.fish;
  fishDir = ../fish;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  nixPathInit = ''
    fish_add_path /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin
  '';
in
{
  options.fish = {
    enable = lib.mkEnableOption "fish shell configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fluxcd
      kubectl
      pyenv
    ];

    programs.fish = {
      enable = true;
      generateCompletions = false;
      plugins = [
        {
          name = "autopair.fish";
          src = pkgs.fishPlugins.autopair.src;
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
          src = pkgs.fishPlugins.nvm.src;
        }
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
      ]
      ++ lib.optionals isDarwin [
        {
          name = "plugin-osx";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-osx";
            rev = "27039b251201ec2e70d8e8052cbc59fa0ac3b3cd";
            sha256 = "032yfxz10vypywfivggsam77b8zplmgafbc0gqks8cxhfy9hh9cd";
          };
        }
      ]
      ++ lib.optionals (!isDarwin) [
        {
          name = "pbcopy";
          src = pkgs.fetchFromGitHub {
            owner = "oh-my-fish";
            repo = "plugin-pbcopy";
            rev = "e8d78bb01f66246f7996a4012655b8ddbad777c2";
            sha256 = "1bmy46mifjbjy9fj2rqiypj94g9ww7spaxgakssvz59rv6sg9bq7";
          };
        }
      ];
    };

    xdg.configFile = {
      "fish/conf.d/00-colors.fish".source = "${fishDir}/conf.d/00-colors.fish";
      "fish/conf.d/01-dotfiles.fish".source = "${fishDir}/config.fish";
      "fish/completions/et.fish".source = "${fishDir}/completions/et.fish";
      "fish/conf.d/eza_aliases.fish".source = "${fishDir}/conf.d/eza_aliases.fish";
      "fish/conf.d/git_aliases.fish".source = "${fishDir}/conf.d/git_aliases.fish";
      "fish/conf.d/kubectl_aliases.fish".source = "${fishDir}/conf.d/kubectl_aliases.fish";
      "fish/functions/cl.fish".source = "${fishDir}/functions/cl.fish";
      "fish/functions/git_current_branch.fish".source = "${fishDir}/functions/git_current_branch.fish";
      "fish/functions/git_develop_branch.fish".source = "${fishDir}/functions/git_develop_branch.fish";
      "fish/functions/git_feature_branch.fish".source = "${fishDir}/functions/git_feature_branch.fish";
      "fish/functions/git_main_branch.fish".source = "${fishDir}/functions/git_main_branch.fish";
      "fish/functions/gitclcd.fish".source = "${fishDir}/functions/gitclcd.fish";
      "fish/functions/mkdir.fish".source = "${fishDir}/functions/mkdir.fish";
      "fish/conf.d/00-tide-config.fish".source = "${fishDir}/conf.d/00-tide-config.fish";
      "fish/conf.d/z-tide-reload.fish".source = "${fishDir}/conf.d/z-tide-reload.fish";
    }
    // lib.optionalAttrs isDarwin {
      "fish/conf.d/00-nix-path.fish".text = nixPathInit;
    };
  };
}
