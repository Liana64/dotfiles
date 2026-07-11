# @desc: probe — cluster-side connectivity checks through the netshoot pod
_: {
  flake.modules.homeManager.probe = {pkgs, ...}: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "probe";
        paths = [(pkgs.writeShellScriptBin "probe" (builtins.readFile ../bin/probe))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/probe \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.kubectl]}
        '';
      })
    ];
  };
}
