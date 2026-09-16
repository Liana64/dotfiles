# @desc: ctar — signed+encrypted tar archives using YubiKey
{...}: {
  flake.modules.homeManager.ctar = {
    lib,
    pkgs,
    ...
  }: let
    deps = with pkgs; [coreutils findutils gnugrep gnupg gnutar gzip zstd];
    script =
      pkgs.writeShellScriptBin "ctar"
      (builtins.readFile ../bin/ctar);
    ctar = pkgs.symlinkJoin {
      name = "ctar";
      paths = [script];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/ctar --prefix PATH : ${lib.makeBinPath deps}
      '';
    };
  in {
    home.packages = [ctar];
  };
}
