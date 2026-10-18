# Settings shared by every NixOS host (servers and WSL).
{ lib, ... }:
{
  system.stateVersion = "24.11";
  time.timeZone = lib.mkDefault "America/Los_Angeles";
  services.vscode-server.enable = true;
}
