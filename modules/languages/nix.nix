# @desc: Nix language — nixd with flake-aware option completion, alejandra formatting
{...}: {
  flake.modules.homeManager.helix = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    host =
      if osConfig == null
      then "framework"
      else osConfig.networking.hostName;
    flake = ''builtins.getFlake "/nix/dotfiles"'';
  in {
    programs.helix.extraPackages = [pkgs.nixd];

    programs.helix.languages = {
      language-server.nixd = {
        command = "nixd";
        config.nixd = {
          nixpkgs.expr = "import (${flake}).inputs.nixpkgs { }";
          options.nixos.expr = "(${flake}).nixosConfigurations.${host}.options";
          options.home_manager.expr = ''(${flake}).homeConfigurations."liana@${host}".options'';
        };
      };

      language = [
        {
          name = "nix";
          language-servers = ["nixd"];
          formatter.command = lib.getExe pkgs.alejandra;
          auto-format = true;
        }
      ];
    };
  };
}
