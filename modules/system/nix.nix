# @desc: Nix daemon: gc, optimise, flake registry
{...}: {
  flake.modules.nixos.nixDaemon = {
    lib,
    inputs,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
    # gc/optimise run the client directly: it remounts /nix/store rw inside a
    # private mount namespace (SYS_ADMIN + mnt). gc's root discovery must see
    # /proc of every process (SYS_PTRACE, no invisible proc), traverse 700
    # homes and 0400 /proc environ (DAC_READ_SEARCH), and resolve gcroot
    # symlinks into homes — hiding any of these silently collects live paths.
    # nix-daemon stays untouched — build isolation is the nix sandbox's own job
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
    # gc additionally resolves roots anchored in /tmp (nh result links) — a
    # private /tmp would silently collect them
    systemd.services.nix-gc.serviceConfig = maintenance // {PrivateTmp = false;};
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
      # Make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

    nixpkgs.config.allowUnfree = true;

    # Fix `man -k`
    documentation.man.cache.enable = true;
  };
}
