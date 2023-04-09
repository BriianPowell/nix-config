{ config, pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Build Tools
    deno # https://deno.land/
    ruby # https://www.ruby-lang.org/en/
    # nodejs-16_x

    # Terminal Tools
    tmux # https://github.com/tmux/tmux
    fish # https://fishshell.com/
    git # https://git-scm.com/
    eternal-terminal # https://eternalterminal.dev/
    bat # https://github.com/sharkdp/bat
    lynx # https://lynx.invisible-island.net/
    most # https://www.jedsoft.org/most/index.html
    ncdu # https://dev.yorhel.nl/ncdu
    curl # https://curl.se/
    wget # https://www.gnu.org/software/wget/

    # System Monitoring
    htop # https://github.com/htop-dev/htop/
    bottom # https://github.com/ClementTsang/bottom
    bind # https://www.isc.org/bind/
    # dig # https://www.isc.org/bind/
    pciutils # https://mj.ucw.cz/sw/pciutils/

    jq # https://stedolan.github.io/jq/
    ripgrep # https://github.com/BurntSushi/ripgrep

    fishPlugins.tide
    fishPlugins.autopair-fish
  ];

  programs.fish.enable = true;
}
