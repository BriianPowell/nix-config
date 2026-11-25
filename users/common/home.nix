# Home Manager profile shared by every account I use (macOS and Linux/WSL):
# the module set, the modules enabled everywhere, and the values they share.
# Per-user files add to this; they only list what differs.
{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  # Dracula PRO is licensed for three computers: the Mac and the two servers. Any other
  # host (gehenna) gets vim without it. See vim/dracula-pro.nix.
  draculaProHosts = [
    "boog-MBP"
    "sheol"
    "abaddon"
  ];
in
{
  imports = [
    ../../home
    ./atuin.nix
    ./git.nix
  ];

  atuin.enable = true;
  git.enable = true;
  fish.enable = true;
  ssh.enable = true;
  tmux.enable = true;
  tooling.enable = true;
  vim = {
    enable = true;
    vimrcFile = ./vim/vimrc;
    themes = lib.optionalAttrs (lib.elem osConfig.networking.hostName draculaProHosts) {
      dracula-pro = import ./vim/dracula-pro.nix { inherit pkgs; };
    };
  };
}
