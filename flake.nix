{
  description = "Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    # EasyEffects profile
    framework-dsp = {
      #url = "github:cab404/framework-dsp/6e5b8e7a5d1f422bcaa2f237f28223fe2292ca38";
      url = "github:cab404/framework-dsp";
      flake = false;
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Staged for impermanence migration. Not yet consumed by any host.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #impermanence.url = "github:nix-community/impermanence";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    lanzaboote,
    ...
  } @ inputs: let
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;
    colors = import ./modules/common/colors/blueberry.nix { };
    lib = nixpkgs.lib;

    mkUnstable = system: import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    homeArgs = { system, unstable }: { inherit inputs colors; }
      // lib.optionalAttrs unstable { nixpkgs-unstable = mkUnstable system; };

    mkNixos = { host, system ? "x86_64-linux", withUnstable ? true }:
      lib.nixosSystem {
        specialArgs = { inherit inputs colors; };
        modules = [
          ./hosts/${host}/configuration.nix
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.liana = import ./hosts/${host}/home.nix;
            home-manager.extraSpecialArgs = homeArgs { inherit system; unstable = withUnstable; };
          }
        ];
      };

    mkHome = { host, system ? "x86_64-linux", withUnstable ? true }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = homeArgs { inherit system; unstable = withUnstable; };
        modules = [ ./hosts/${host}/home.nix ];
      };
  in {
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    #packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    #overlays = import ./overlays {inherit inputs;};

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    #nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    #homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      framework = mkNixos { host = "framework"; };
      portable = mkNixos { host = "portable"; };
      oob = mkNixos { host = "oob"; withUnstable = false; };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "liana@framework" = mkHome { host = "framework"; };
      "liana@portable" = mkHome { host = "portable"; };
      "liana@oob" = mkHome { host = "oob"; system = "aarch64-linux"; withUnstable = false; };
      "liana@small" = mkHome { host = "small"; system = "aarch64-darwin"; withUnstable = false; };
    };
  };
}
