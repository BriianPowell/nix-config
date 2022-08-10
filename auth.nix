# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
in
{
  imports = [
    # <home-manager/nixos>
    (import "${home-manager}/nixos")

    ./users/dudeofawesome.nix
  ];

  # Define user accounts.
  users = {
    mutableUsers = false;

    users = {
      # root.hashedPassword = "!";
      root.passwordFile = "/etc/passwd-dudeofawesome";
    };
  };

  # Don't require password for sudo.
  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;

    permitRootLogin = "no";

    # disable password authentication
    passwordAuthentication = false;
    # challengeResponseAuthentication = false;
    kbdInteractiveAuthentication = false;

    forwardX11 = false;
  };
  services.eternal-terminal.enable = true;
}
