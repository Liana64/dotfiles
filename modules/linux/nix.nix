{ config, lib, ... }: {
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [ "nix-command flakes" ];
      warn-dirty = false;
      fallback = true;
      connect-timeout = 1;
      allowed-users = [ "@wheel" ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Fix `man -k`
  documentation.man.generateCaches = true;
}
