# @desc: frame — dotfiles just runner
{...}: {
  flake.modules.homeManager.frame = {
    pkgs,
    flakePath,
    ...
  }: {
    home.packages = [
      (pkgs.writeShellScriptBin "frame" ''
        exec ${pkgs.just}/bin/just --justfile ${flakePath}/justfile \
          --working-directory ${flakePath} "$@"
      '')
    ];
  };
  perSystem = {pkgs, ...}: {
    checks.justfile = pkgs.runCommand "justfile-check" {} ''
      ${pkgs.just}/bin/just --justfile ${../../justfile} --list > $out
    '';
  };
}
