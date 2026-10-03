# @desc: Nix daemon: gc, optimise, flake registry
{...}: {
  flake.modules.nixos.nixDaemon = {
    config,
    lib,
    inputs,
    hardening,
    ...
  }: let
    maintenance =
      hardening.base
      // {
        CapabilityBoundingSet = "CAP_SYS_ADMIN CAP_SYS_PTRACE CAP_DAC_READ_SEARCH";
        RestrictNamespaces = "mnt";
        ProtectProc = "default";
        ProtectHome = "read-only";
        PrivateNetwork = true;
        PrivateDevices = true;
        RestrictAddressFamilies = "AF_UNIX";
        SystemCallArchitectures = "native";
      };
  in {
    systemd.services.nix-gc.serviceConfig =
      maintenance
      // {
        PrivateTmp = false;
        CapabilityBoundingSet = "${maintenance.CapabilityBoundingSet} CAP_DAC_OVERRIDE CAP_FOWNER";
      };
    systemd.services.nix-optimise.serviceConfig = maintenance;

    nix = let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in {
      optimise.automatic = true;
      gc = {
        automatic = true;
        dates = "Fri 11:00";
        options = "--delete-older-than 30d";
      };
      settings = {
        experimental-features = ["nix-command" "flakes"];
        warn-dirty = false;
        fallback = true;
        connect-timeout = 1;
        allowed-users = ["@wheel"];
      };

      channel.enable = false;
      registry = lib.mapAttrs (_: flake: {inherit flake;}) (removeAttrs flakeInputs ["nixpkgs"]);
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    assertions = [
      {
        assertion = (config.nix.settings.trusted-users or ["root"]) == ["root"];
        message = "nix.settings.trusted-users grew beyond root";
      }
    ];

    nixpkgs.config.allowUnfree = true;

    # Fix `man -k`
    documentation.man.cache.enable = true;
  };
}
