# @desc: YAML language — yamlls with pinned schemas (taskfile, github-workflow, kustomization)
{...}: {
  flake.modules.homeManager.helix = {
    pkgs,
    lib,
    config,
    ...
  }: let
    schemastore = name: "https://raw.githubusercontent.com/SchemaStore/schemastore/d9cf444ea70865b42f554a1877e592f159e98439/src/schemas/json/${name}.json";

    schemas = {
      taskfile = {
        url = "https://raw.githubusercontent.com/go-task/task/ff3372fc50a47348610d722616f1a073aace0513/website/src/public/schema.json";
        hash = "sha256-fMCdR9Hwm4BhO4OsBZjHNt9fC+XACYVMfGPzmi85KMI=";
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
    programs.helix.extraPackages = [pkgs.yaml-language-server];

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
      language-server.yaml-language-server.config = {
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

      language = [
        {
          name = "yaml";
          auto-format = true;
        }
      ];
    };
  };
}
