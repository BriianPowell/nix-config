# Nix daemon and home-manager defaults shared by every machine (NixOS and
# nix-darwin). Trusted users are not listed here: each user module under
# users/ adds its own name to `nix.settings.trusted-users`.
{ inputs, ... }:
{
  nix.settings = {
    max-jobs = 4;
    cores = 0;
    sandbox = true;
    substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cachix.org"
    ];
    experimental-features = [
      "nix-command"
    ];
    warn-dirty = false;
    keep-outputs = true;
    keep-derivations = true;
    http-connections = 50;
    log-lines = 50;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # Back up existing files before HM replaces them (e.g. iterm2 plist, git ignore).
    backupFileExtension = "backup";
  };
}
