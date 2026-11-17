{
  description = "NixOS configs for thinkpad (T460p) and desktop (Ryzen 5 3600 / RX 5700 XT)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mprissence = {
      url = "github:mistychirp/mprissence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    craft-launcher = {
      url = "github:storytold/craft-launcher";
      flake = false;
    };

    # The makshell desktop on KWin, as its own login session (modules/common.nix).
    makshell = {
      # Over SSH: the repository is private.
      url = "git+ssh://git@github.com/mistychirp/makshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        thinkpad = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/thinkpad/configuration.nix
            ./modules/common.nix
            ./modules/laptop.nix
            ./modules/locales.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.misty = import ./home/misty/home.nix;
            }
          ];
        };

        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/desktop/configuration.nix
            ./modules/common.nix
            ./modules/desktop-gpu.nix
            ./modules/locales.nix
            ./modules/robco-pmsd.nix
            ./modules/llm.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.misty = import ./home/misty/home.nix;
            }
          ];
        };
      };
    };
}
