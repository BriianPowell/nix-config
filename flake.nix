{
  description = "Nix 4 Lyfe";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      util = import ./lib {
        inherit system pkgs home-manager lib; overlays = (pkgs.overlays);
      };

      inherit (util) user;
      inherit (util) host;

      pkgs = import nixpkgs {
        inherit system;
        # config.allowUnfree = true;
        overlays = [ ];
      };

      system = "x86_64-linux";
    in
    {
      #   packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;
      #   packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

      homeManagerConfigurations = {
        boog = user.mkHMUser {
          # ...
        };
      };

      nixosConfigurations = {
        sheol = host.mkHost {
          # ...
        };
      };
    };

}
