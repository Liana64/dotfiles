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
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
}
