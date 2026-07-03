{
  description = "Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #niri = {
    #  url = "github:sodiboo/niri-flake";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.nixpkgs-stable.follows = "nixpkgs";
    #};

    dice = {
      url = "git+ssh://git@git.milberry.org/liana/dice.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Liana64/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-encrypted state, PQ age recipients only (see secretstore README).
    secrets = {
      url = "git+ssh://git@git.milberry.org/liana/secrets.git";
      flake = false;
    };

    # Staged for impermanence migration. Not yet consumed by any host.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #impermanence.url = "github:nix-community/impermanence";

    taskwarrior-tui-src = {
      url = "github:Liana64/taskwarrior-tui/feature/nested-tasks";
      flake = false;
    };

    # Pinned firmware source for the Keychron Q11 build (embedded/keychron-q11).
    # Locked in flake.lock incl. submodules; fetched only when the app is run.
    qmk-firmware = {
      url = "github:qmk/qmk_firmware/486f01f5133b3d2adf27ec546ca7fa05dbf548f1?submodules=1";
      flake = false;
    };
  };

  # Logic added here bypasses import-tree; keep flake.nix to inputs + this call.
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [(inputs.import-tree ./modules)];
    };
}
