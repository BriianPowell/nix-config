# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Define user accounts.
  users = {
    users = {
      dudeofawesome = {
        description = "Louis Orleans";
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [ "wheel" "docker" ];
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMhI7UVBgKfEK7k2vjE51SBvmlL4tKp6Y54SoI8yDFX" ];
      };
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
}
