{ pkgs, ... }: {
  nix = {
    package = pkgs.nixFlakes;
    gc = {
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
    '';
  };
}
