{ config, lib, inputs, ... }: {
  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "Fri 11:00";
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

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [ "-L" ];
    dates = "Fri 09:00";
    randomizedDelaySec = "15min";
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  # Fix `man -k`
  documentation.man.generateCaches = true;
}
