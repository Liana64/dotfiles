# @desc: infra — home-infra Taskfile runner with bare-name task resolution
{...}: {
  flake.modules.homeManager.infra = {
    pkgs,
    nixpkgs-unstable,
    ...
  }: let
    tools = import ../_lib/infra-tools.nix {
      inherit pkgs;
      unstable = nixpkgs-unstable;
    };
  in {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "infra";
        paths = [(pkgs.writeShellScriptBin "infra" (builtins.readFile ../bin/infra))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/infra \
            --prefix PATH : ${pkgs.lib.makeBinPath tools}
        '';
      })
    ];
  };
}
