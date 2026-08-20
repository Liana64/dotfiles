# @desc: Steel plugin framework — declared cogs materialized into STEEL_HOME + init.scm
{...}: {
  flake.modules.homeManager.helix = {
    config,
    lib,
    ...
  }: let
    cfg = config.programs.helix.steel;

    cog = lib.types.submodule {
      options = {
        src = lib.mkOption {
          type = lib.types.path;
          description = "Source tree of the cog (directory containing cog.scm).";
        };
        require = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "Module paths required from init.scm, relative to the cogs root.";
        };
        init = lib.mkOption {
          type = lib.types.lines;
          default = "";
          description = "Scheme evaluated after the requires: setup calls, keymaps.";
        };
      };
    };

    load = plugin:
      map (m: ''(require "${m}")'') plugin.require
      ++ lib.optional (plugin.init != "") plugin.init;
  in {
    options.programs.helix.steel.plugins = lib.mkOption {
      type = lib.types.attrsOf cog;
      default = {};
      description = "Steel cogs keyed by package name; inert until programs.helix.package carries the Steel runtime.";
    };

    config = lib.mkIf (cfg.plugins != {}) {
      home.sessionVariables.STEEL_HOME = "${config.xdg.dataHome}/steel";

      xdg.dataFile =
        lib.mapAttrs'
        (name: plugin: lib.nameValuePair "steel/cogs/${name}" {source = plugin.src;})
        cfg.plugins;

      xdg.configFile."helix/init.scm".text =
        lib.concatLines (lib.flatten (lib.mapAttrsToList (_: load) cfg.plugins));
    };
  };
}
