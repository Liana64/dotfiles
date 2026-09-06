# @desc: tarback — tar a path into ~/Backups/<date>--<name>.tar
{...}: {
  flake.modules.homeManager.tarback = {
    lib,
    pkgs,
    ...
  }: let
    deps = with pkgs; [coreutils gnutar];
    script =
      pkgs.writeShellScriptBin "tarback"
      (builtins.readFile ../bin/tarback);
    tarback = pkgs.symlinkJoin {
      name = "tarback";
      paths = [script];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/tarback --prefix PATH : ${lib.makeBinPath deps}
      '';
    };
  in {
    home.packages = [tarback];
  };
}
