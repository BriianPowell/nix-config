# Settings shared by every NixOS host (servers and WSL).
{ lib, ... }:
{
  imports = [
    ./cli.nix
    ./fonts.nix
    ./nix-settings.nix
    ./secrets.nix
  ];

  system.stateVersion = "24.11";
  time.timeZone = lib.mkDefault "America/Los_Angeles";
  services.vscode-server.enable = true;
}
