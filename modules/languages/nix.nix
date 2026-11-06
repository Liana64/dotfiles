# @desc: Nix language — nixd with flake-aware option completion, alejandra formatting
{user, ...}: {
  flake.modules.homeManager.helix = {
    pkgs,
    lib,
    osConfig,
    flakePath,
    ...
  }: let
    host =
      if osConfig == null
      then "framework"
      else osConfig.networking.hostName;
    flake = ''builtins.getFlake "${flakePath}"'';
  in {
    programs.helix.extraPackages = [pkgs.nixd];

    programs.helix.languages = {
      language-server.nixd = {
        command = "nixd";
        config.nixd = {
          nixpkgs.expr = "import (${flake}).inputs.nixpkgs { }";
          options.nixos.expr = "(${flake}).nixosConfigurations.${host}.options";
          options.home_manager.expr = ''(${flake}).homeConfigurations."${user.name}@${host}".options'';
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
