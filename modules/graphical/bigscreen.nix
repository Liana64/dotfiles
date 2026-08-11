# @desc: Plasma Bigscreen TV session (compositor = bigscreen)
{...}: {
  flake.modules.nixos.bigscreen = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    useBigscreen = config.compositor == "bigscreen";
  in {
    config = lib.mkIf useBigscreen {
      nixpkgs.overlays = [
        (_final: prev: {
          inherit
            (import inputs.nixpkgs-unstable {
              inherit (prev.stdenv.hostPlatform) system;
              config.allowUnfree = true;
            })
            kdePackages
            ;
        })
      ];

      services = {
        desktopManager.plasma6.enable = true;

        displayManager = {
          sessionPackages = [pkgs.kdePackages.plasma-bigscreen];
          defaultSession = "plasma-bigscreen-wayland";
          sddm = {
            enable = true;
            wayland.enable = true;
          };
          autoLogin = {
            enable = true;
            user = "liana";
          };
        };
      };
    };
  };
}
