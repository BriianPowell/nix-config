# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./users/dudeofawesome.nix
  ];

  # Define user accounts.
  users = {
    mutableUsers = false;

    users = {
      # root.hashedPassword = "!";
      root.passwordFile = "/etc/passwd-dudeofawesome";

      dudeofawesome = {
        description = "Louis Orleans";
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [ "wheel" "docker" ];
        passwordFile = "/etc/passwd-dudeofawesome";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMhI7UVBgKfEK7k2vjE51SBvmlL4tKp6Y54SoI8yDFX"
        ];
      };
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
    challengeResponseAuthentication = false;
    # kbdInteractiveAuthentication = false;

    forwardX11 = false;
  };
  services.eternal-terminal.enable = true;
}
