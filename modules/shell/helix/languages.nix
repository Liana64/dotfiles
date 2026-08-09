# @desc: Helix language servers — nixd, yamlls, lua-ls, all from nixpkgs
{...}: {
  flake.modules.homeManager.helix = {
    programs.helix.languages = {
      language-server = {
        nixd = {
          command = "nixd";
          config.nixd = {
            nixpkgs.expr = ''import (builtins.getFlake "/nix/dotfiles").inputs.nixpkgs { }'';
            options = {
              nixos.expr = ''(builtins.getFlake "/nix/dotfiles").nixosConfigurations.framework.options'';
              home_manager.expr = ''(builtins.getFlake "/nix/dotfiles").homeConfigurations."liana@framework".options'';
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
          };
        };

        lua-language-server.config.Lua.telemetry.enable = false;
      };

      language = [
        {
          name = "nix";
          language-servers = ["nixd"];
        }
      ];
    };
  };
}
