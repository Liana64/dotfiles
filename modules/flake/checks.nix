# @desc: Flake checks: secrets-guard + ai-memory fixtures, shellcheck on the wrapped scripts
{lib, ...}: {
  perSystem = {pkgs, ...}: let
    bin = ../bin;
    scripts = lib.attrNames (lib.filterAttrs (_: type: type == "regular") (builtins.readDir bin));
  in {
    checks.secrets-guard = let
      patterns = import ../_lib/secret-patterns.nix;
    in
      pkgs.runCommand "secrets-guard-test" {nativeBuildInputs = [pkgs.jq];} ''
        set -o pipefail
        CLAUDE_SECRET_GLOBS=${lib.escapeShellArg (lib.concatStringsSep " " patterns.globs)} \
          CLAUDE_SECRET_DIRS=${lib.escapeShellArg (lib.concatStringsSep " " patterns.dirs)} \
          sh ${bin}/claude-secrets-guard --test | tee $out
      '';
    checks.ai-memory =
      pkgs.runCommand "ai-memory-test" {
        nativeBuildInputs = with pkgs; [git gnugrep gawk findutils coreutils];
      } ''
        set -o pipefail
        HOME=$TMPDIR ${pkgs.bash}/bin/bash ${bin}/ai-memory --test | tee $out
      '';
    checks.bin-shellcheck = pkgs.runCommand "bin-shellcheck" {nativeBuildInputs = [pkgs.shellcheck];} ''
      shellcheck -S warning ${lib.concatMapStringsSep " " (s: "${bin}/${s}") scripts}
      touch $out
    '';
  };
}
