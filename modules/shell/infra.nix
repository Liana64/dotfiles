# @desc: infra — home-infra Taskfile runner with bare-name task resolution
{...}: {
  flake.modules.homeManager.infra = {pkgs, ...}: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "infra";
        paths = [(pkgs.writeShellScriptBin "infra" (builtins.readFile ../bin/infra))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/infra \
            --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.go-task pkgs.jq pkgs.k9s pkgs.kubectl]}
        '';
      })
    ];
  };
}
