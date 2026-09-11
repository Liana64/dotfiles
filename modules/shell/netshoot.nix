# @desc: netshoot — cluster-side connectivity checks through the netshoot pod
_: {
  flake.modules.homeManager.netshoot = {pkgs, ...}: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "netshoot";
        paths = [(pkgs.writeShellScriptBin "netshoot" (builtins.readFile ../bin/netshoot))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/netshoot \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.kubectl]}
        '';
      })
    ];
  };
}
