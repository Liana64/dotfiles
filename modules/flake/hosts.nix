# @desc: Assembles nixosConfigurations + homeConfigurations from aspects
{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) self nixpkgs home-manager;

  nixosAspects = lib.attrValues (config.flake.modules.nixos or {});
  homeAspects = lib.attrValues (config.flake.modules.homeManager or {});

  hosts = {
    framework.system = "x86_64-linux";
    portable.system = "x86_64-linux";
    noku.system = "x86_64-linux";
    m1 = {
      system = "x86_64-linux";
      aspects = ["nixDaemon" "time" "users"];
      home = false;
    };
    oob = {
      system = "aarch64-linux";
      channel = inputs.nixpkgs-unstable;
      aspects = ["nixDaemon" "time" "users"];
      home = false;
    };
  };

  mkUnstable = system:
    import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  homeExtra = system: {
    inherit inputs;
    nixpkgs-unstable = mkUnstable system;
  };

  # Home base shared by the NixOS-embedded and standalone home configs.
  hmShared = {
    home.username = "liana";
    home.homeDirectory = "/home/liana";
    home.stateVersion = "26.05";
    home.file.".wallpapers" = {
      source = ../../share/wallpapers;
      recursive = true;
    };
    home.sessionVariables.NIX_CONFIG = "experimental-features = nix-command flakes";
    programs.home-manager.enable = true;
    nixpkgs.config.allowUnfree = true;
    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  mkNixos = name: {
    system,
    aspects ? null,
    home ? true,
    channel ? nixpkgs,
  }:
    channel.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules =
        (
          if aspects == null
          then nixosAspects
          else lib.attrVals aspects config.flake.modules.nixos
        )
        ++ ["${self}/hosts/${name}/options.nix"]
        ++ lib.optionals home [
          home-manager.nixosModules.home-manager
          {
            home-manager.useUserPackages = true;
            home-manager.users.liana.imports = homeAspects ++ [hmShared];
            home-manager.extraSpecialArgs = homeExtra system;
          }
        ];
    };

  mkHome = {system, ...}:
    home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = homeExtra system;
      modules = homeAspects ++ [hmShared];
    };
in {
  flake.nixosConfigurations = lib.mapAttrs mkNixos hosts;
  flake.homeConfigurations =
    lib.mapAttrs' (name: h: lib.nameValuePair "liana@${name}" (mkHome h))
    (lib.filterAttrs (_: h: h.home or true) hosts);
}
