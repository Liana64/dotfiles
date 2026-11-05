# @desc: Planify (CalDAV tasks)
{...}: {
  flake.modules.homeManager.planify = {pkgs, ...}: let
    inherit (pkgs) planify;
    overrides = pkgs.writeText "planify.gschema.override" ''
      [io.github.alainm23.planify]
      calendar-enabled=false
      run-in-background=false
      run-on-startup=false
      task-complete-tone=false
    '';
    schemas = pkgs.runCommand "planify-schemas" {nativeBuildInputs = [pkgs.glib];} ''
      mkdir $out
      cp ${pkgs.glib.getSchemaPath planify}/*.xml $out/
      cp ${overrides} $out/90_planify.gschema.override
      glib-compile-schemas $out
    '';
  in {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "planify";
        paths = [planify];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          for b in $out/bin/*; do
            wrapProgram $b --set GSETTINGS_BACKEND keyfile --set GSETTINGS_SCHEMA_DIR ${schemas}
          done
        '';
      })
    ];
  };
}
