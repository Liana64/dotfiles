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
  workstation =
    hardened
    ++ [
      "audio"
      "auditd"
      "boot"
      "compositor"
      "email"
      "faillock"
      "files"
      "flatpak"
      "fonts"
      "hardeningWorkstation"
      "impermanence"
      "keyboard"
      "keyring"
      "logFlood"
      "networking"
      "nfsClient"
      "nushell"
      "packages"
      "secrets"
      "ssd"
      "sudo"
      "tasks"
      "theme"
      "usbguard"
      "virtualization"
      "wireguard"
      "wireless"
      "yubikey"
    ];
  laptop = workstation ++ ["frameworkHardware" "laptop"];

  hosts = {
    framework = {
      system = "x86_64-linux";
      aspects = laptop;
    };
    portable = {
      system = "x86_64-linux";
      aspects = laptop;
    };
    noku = {
      system = "x86_64-linux";
      aspects = workstation ++ ["bigscreen"];
    };
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
    offsite-1 = {
      system = "aarch64-linux";
      aspects = hardened ++ ["impermanence" "sudo"];
      home = false;
    };
    oob = {
      system = "aarch64-linux";
      channel = inputs.nixpkgs-unstable;
      aspects = base;
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
    aspects,
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
