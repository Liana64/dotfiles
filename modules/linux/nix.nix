# @desc: Nix daemon: gc, optimise, flake registry
{ lib, inputs, ... }: {
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
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      fallback = true;
      connect-timeout = 1;
      allowed-users = [ "@wheel" ];
    };

    channel.enable = false;
    # Make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  nixpkgs.config.allowUnfree = true;

  # Fix `man -k`
  documentation.man.cache.enable = true;
}
