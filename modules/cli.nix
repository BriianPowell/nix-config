{ config, pkgs, lib, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Build Tools
    deno # https://deno.land/
    ruby # https://www.ruby-lang.org/en/
    # nodejs-16_x

    # Terminal Tools
    fish # https://fishshell.com/
    eternal-terminal # https://eternalterminal.dev/
    tmux # https://github.com/tmux/tmux
    git # https://git-scm.com/
    bat # https://github.com/sharkdp/bat
    lynx # https://lynx.invisible-island.net/
    most # https://www.jedsoft.org/most/index.html
    ncdu # https://dev.yorhel.nl/ncdu
    curl # https://curl.se/
    wget # https://www.gnu.org/software/wget/
    nurl # https://github.com/nix-community/nurl
    # httpie # https://httpie.io/

    jq # https://stedolan.github.io/jq/
    ripgrep # https://github.com/BurntSushi/ripgrep

    # helix # https://helix-editor.com/

    # System Monitoring
    htop # https://github.com/htop-dev/htop/
    bottom # https://github.com/ClementTsang/bottom
    bind # https://www.isc.org/bind/
    # dig # https://www.isc.org/bind/
    pciutils # https://mj.ucw.cz/sw/pciutils/

    # Terminal Plugins
    fishPlugins.tide
    fishPlugins.autopair-fish
  ];
}
