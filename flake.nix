{
  description = "Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
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
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #niri = {
    #  url = "github:sodiboo/niri-flake";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #  inputs.nixpkgs-stable.follows = "nixpkgs";
    #};

    # Curated fortune file + dice wrapper; single source of truth for the data.
    dice = {
      url = "git+ssh://git@git.milberry.org/liana/dice.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Staged for impermanence migration. Not yet consumed by any host.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #impermanence.url = "github:nix-community/impermanence";

    # Fork for nested tasks
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
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    lib = nixpkgs.lib;

    mkUnstable = system: import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    homeArgs = { system, unstable }: { inherit inputs; }
      // lib.optionalAttrs unstable { nixpkgs-unstable = mkUnstable system; };

    mkNixos = { host, system ? "x86_64-linux", withUnstable ? true }:
      lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/${host}/configuration.nix
          lanzaboote.nixosModules.lanzaboote
          # inputs.niri.nixosModules.niri
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
        modules = [
          # inputs.niri.homeModules.niri
          ./hosts/${host}/home.nix
        ];
      };

    # Keychron Q11 firmware builder/flasher. Run on demand (`nix run`), never
    # installed — the qmk + ARM toolchain closure is fetched only when used.
    mkKeychronQ11 = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in pkgs.symlinkJoin {
      name = "keychron-q11";
      paths = [
        (pkgs.writeShellScriptBin "keychron-q11"
          (builtins.readFile ./modules/linux/bin/keychron-q11))
      ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/keychron-q11 \
          --prefix PATH : ${lib.makeBinPath (with pkgs; [ git qmk gnumake gcc-arm-embedded dfu-util coreutils ])} \
          --set KEYMAP_DIR ${./embedded/keychron-q11} \
          --set QMK_SRC ${inputs.qmk-firmware}
      '';
    };

    # Module index: a CLAUDE.md map derived from per-file `# @desc:` comments.
    # `nix run .#gen-index` rewrites the marker block; `nix flake check` gates drift.
    moduleIndexBody = let
      descOf = path: let
        hit = lib.findFirst (l: lib.hasInfix "@desc:" l) null
          (lib.splitString "\n" (builtins.readFile path));
      in if hit == null then "" else lib.trim (lib.elemAt (lib.splitString "@desc:" hit) 1);
      rel = p: lib.removePrefix (toString ./. + "/") (toString p);
      leaves = dir: lib.filter
        (p: lib.hasSuffix ".nix" (toString p) && baseNameOf (toString p) != "default.nix")
        (lib.filesystem.listFilesRecursive dir);
      files = lib.sort (a: b: rel a < rel b) (leaves ./modules ++ leaves ./home);
      rows = map (p: "| `${rel p}` | ${descOf p} |") files;
    in lib.concatStringsSep "\n" ([ "| File | Description |" "| --- | --- |" ] ++ rows);

    mkIndexFile = system:
      nixpkgs.legacyPackages.${system}.writeText "module-index.md" (moduleIndexBody + "\n");

    genIndexApp = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      type = "app";
      program = toString (pkgs.writeShellScript "gen-index" ''
        set -eu
        target=''${1:-CLAUDE.md}
        ${pkgs.gawk}/bin/awk -v blockfile=${mkIndexFile system} '
          BEGIN { while ((getline line < blockfile) > 0) block = block line "\n" }
          /<!-- BEGIN module-index -->/ { print; printf "%s", block; skip=1; next }
          /<!-- END module-index -->/ { skip=0 }
          !skip { print }
        ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
      '');
    };

    checkModuleIndex = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in pkgs.runCommand "check-module-index" { } ''
      ${pkgs.gawk}/bin/awk '/<!-- BEGIN module-index -->/{f=1;next} /<!-- END module-index -->/{f=0} f' \
        ${./CLAUDE.md} > current
      if diff -u ${mkIndexFile system} current; then touch $out; else
        echo "CLAUDE.md module-index is stale; run: nix run .#gen-index" >&2; exit 1
      fi
    '';
  in {
    packages = forAllSystems (system: {
      keychron-q11 = mkKeychronQ11 system;
      module-index = mkIndexFile system;
    });

    apps = forAllSystems (system: {
      keychron-q11 = {
        type = "app";
        program = "${mkKeychronQ11 system}/bin/keychron-q11";
      };
      gen-index = genIndexApp system;
    });

    checks = forAllSystems (system: {
      module-index = checkModuleIndex system;
    });

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Add if needed: overlays, nixosModules, homeManagerModules.

    nixosConfigurations = {
      framework = mkNixos { host = "framework"; };
      portable = mkNixos { host = "portable"; };
    };

    homeConfigurations = {
      "liana@framework" = mkHome { host = "framework"; };
      "liana@portable" = mkHome { host = "portable"; };
    };
  };
}
