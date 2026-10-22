# @desc: Assembles nixosConfigurations + homeConfigurations from aspects
{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs) self nixpkgs home-manager;

  homeAspects = lib.attrValues (config.flake.modules.homeManager or {});

  base = ["hardwareTools" "nixDaemon" "time" "users"];
  hardened = base ++ ["hardening" "journald" "noDefaults" "noexec" "storeVerify"];
  serverOnly = ["hypervisor" "zfsRollback"];
  optIn = ["perfTools"];
  workstation = lib.attrNames (removeAttrs config.flake.modules.nixos (optIn ++ serverOnly));

  hosts = {
    framework.system = "x86_64-linux";
    portable.system = "x86_64-linux";
    noku.system = "x86_64-linux";
    m1 = {
      system = "x86_64-linux";
      aspects = hardened ++ ["hypervisor"];
      home = false;
    };
    n1 = {
      system = "x86_64-linux";
      aspects = hardened ++ serverOnly;
      home = false;
    };
    n2 = {
      system = "x86_64-linux";
      aspects = hardened ++ serverOnly;
      home = false;
    };
    n3 = {
      system = "x86_64-linux";
      aspects = hardened ++ serverOnly;
      home = false;
    };
    oob = {
      system = "aarch64-linux";
      channel = inputs.nixpkgs-unstable;
      aspects = base;
      home = false;
    };
    deck = {
      system = "x86_64-linux";
      channel = inputs.nixpkgs-unstable;
      aspects = base ++ ["noDefaults" "frameworkHardware"];
      home = false;
    };
  };

  mkUnstable = system:
    import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  hardening = import ../_lib/systemd-hardening.nix lib;

  homeExtra = system: {
    inherit inputs hardening;
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
    aspects ? workstation,
    home ? true,
    channel ? nixpkgs,
  }:
    channel.lib.nixosSystem {
      specialArgs = {inherit inputs hardening;};
      modules =
        lib.attrVals aspects config.flake.modules.nixos
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
