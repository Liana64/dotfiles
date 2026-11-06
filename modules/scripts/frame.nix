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
      (pkgs.writeShellApplication {
        name = "rebuild-track";
        runtimeInputs = with pkgs; [coreutils systemd util-linux];
        bashOptions = [];
        text = builtins.readFile ../bin/rebuild-track;
      })
    ];
  };
  perSystem = {pkgs, ...}: {
    checks.justfile = pkgs.runCommand "justfile-check" {} ''
      ${pkgs.just}/bin/just --justfile ${../../justfile} --list > $out
    '';
  };
}
