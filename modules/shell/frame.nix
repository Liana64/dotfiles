# @desc: frame — global just runner for repo/system/hardware/ai tasks
{...}: {
  flake.modules.homeManager.frame = {pkgs, ...}: {
    home.packages = [
      # Live justfile, not a store copy: recipe edits apply without a switch.
      (pkgs.writeShellScriptBin "frame" ''
        exec ${pkgs.just}/bin/just --justfile /nix/dotfiles/justfile \
          --working-directory /nix/dotfiles "$@"
      '')
    ];
  };
  perSystem = {pkgs, ...}: {
    # Syntax-gate the justfile at flake-check time.
    checks.justfile = pkgs.runCommand "justfile-check" {} ''
      ${pkgs.just}/bin/just --justfile ${../../justfile} --list > $out
    '';
  };
}
