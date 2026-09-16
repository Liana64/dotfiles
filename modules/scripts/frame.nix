{...}: {
  flake.modules.homeManager.frame = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "frame" ''
        exec ${pkgs.just}/bin/just --justfile /nix/dotfiles/justfile \
          --working-directory /nix/dotfiles "$@"
      '')
    ];
  };
  perSystem = {pkgs, ...}: {
    checks.justfile = pkgs.runCommand "justfile-check" {} ''
      ${pkgs.just}/bin/just --justfile ${../../justfile} --list > $out
    '';
  };
}
