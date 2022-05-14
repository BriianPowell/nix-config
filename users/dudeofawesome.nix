{ config, pkgs, epkgs, ... }:
{
  home-manager.users.dudeofawesome = {
    programs.git = {
      enable = true;
      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";
    };

    programs.fish.enable = true;
    programs.fish.plugins = [
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.3.1";
          sha256 = "sha256-TR01V4Ol7zAj+3hvBj23PGSNjH+EHTcOQSKtA5uneGE";
        };
      }
    ];

    imports = [
      ../../utils/dotfiles.nix
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
