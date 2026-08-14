# @desc: Helix language servers — nixd, yamlls, lua-ls, all from nixpkgs
{...}: {
  flake.modules.homeManager.helix = {
    pkgs,
    lib,
    config,
    osConfig,
    ...
  }: let
    host =
      if osConfig != null
      then osConfig.networking.hostName
      else "framework";

    schemastore = name: "https://raw.githubusercontent.com/SchemaStore/schemastore/d9cf444ea70865b42f554a1877e592f159e98439/src/schemas/json/${name}.json";

    schemas = {
      taskfile = {
        url = "https://taskfile.dev/schema.json";
        hash = "sha256-wS7JE2JakcFapJ+NML2XX7T6qwsnAJw0Ifm/2qDhmA0=";
        globs = ["**/Taskfile*.yaml" "**/.taskfiles/*.yaml"];
      };
      github-workflow = {
        url = schemastore "github-workflow";
        hash = "sha256-epUv23wbEwcy5AzOqdubztkGwRmOl4NPikmuO0EfMWE=";
        globs = ["**/.github/workflows/*.yaml"];
      };
      kustomization = {
        url = schemastore "kustomization";
        hash = "sha256-UEVQUJutz+qQC/Oe20BFMQIN0viI7GLRbGXr3uYq2aE=";
        globs = ["**/kustomization.yaml"];
      };
    };

    # languages.toml cannot hold store paths, so the schemas materialize under ~/.config.
    dir = "${config.xdg.configHome}/helix/schemas";
  in {
    xdg.configFile = lib.mapAttrs' (name: {
      url,
      hash,
      ...
    }:
      lib.nameValuePair "helix/schemas/${name}.json" {
        source = pkgs.fetchurl {inherit url hash;};
      })
    schemas;

    programs.helix.languages = {
      language-server = {
        nixd = {
          command = "nixd";
          config.nixd = {
            nixpkgs.expr = ''import (builtins.getFlake "/nix/dotfiles").inputs.nixpkgs { }'';
            options = {
              nixos.expr = ''(builtins.getFlake "/nix/dotfiles").nixosConfigurations.${host}.options'';
              home_manager.expr = ''(builtins.getFlake "/nix/dotfiles").homeConfigurations."liana@${host}".options'';
            };
          };
        };

        yaml-language-server.config = {
          redhat.telemetry.enabled = false;
          yaml = {
            validate = true;
            keyOrdering = false;
            format.enable = true;
            schemaStore = {
              enable = false;
              url = "";
            };
            schemas = lib.mapAttrs' (name: {globs, ...}:
              lib.nameValuePair "file://${dir}/${name}.json" globs)
            schemas;
          };
        };

        lua-language-server.config.Lua.telemetry.enable = false;
      };

      language = [
        {
          name = "nix";
          language-servers = ["nixd"];
          formatter.command = lib.getExe pkgs.alejandra;
          auto-format = true;
        }
        {
          name = "yaml";
          auto-format = true;
        }
      ];
    };
  };
}
