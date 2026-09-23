# @desc: dotfiles-verify — quiet flake-eval check for the deployed configs
{...}: {
  flake.modules.homeManager.dotfiles-verify = {
    lib,
    pkgs,
    ...
  }: let
    deps = with pkgs; [nix git coreutils];
    dotfiles-verify = pkgs.symlinkJoin {
      name = "dotfiles-verify";
      paths = [
        (pkgs.writeShellScriptBin "dotfiles-verify"
          (builtins.readFile ../bin/dotfiles-verify))
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/dotfiles-verify --prefix PATH : ${lib.makeBinPath deps}
      '';
    };
  in {
    home.packages = [dotfiles-verify];
  };
}
