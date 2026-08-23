# @desc: nix-build-installer — installer ISO built into the current directory
_: {
  flake.modules.homeManager.installer = {pkgs, ...}: {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "nix-build-installer";
        paths = [(pkgs.writeShellScriptBin "nix-build-installer" (builtins.readFile ../bin/nix-build-installer))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/nix-build-installer \
            --prefix PATH : ${pkgs.lib.makeBinPath (with pkgs; [nix git coreutils openssh])}
        '';
      })
    ];
  };
}
