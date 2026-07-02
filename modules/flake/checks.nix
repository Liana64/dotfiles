# @desc: Flake checks: secrets-guard fixture + shellcheck on the wrapped scripts
{lib, ...}: {
  perSystem = {pkgs, ...}: let
    bin = ../bin;
    scripts = ["ai-memory" "claude-nix-check" "claude-secrets-guard" "claude-statusline" "dotfiles-verify" "hardening-probe"];
  in {
    checks.secrets-guard = pkgs.runCommand "secrets-guard-test" {nativeBuildInputs = [pkgs.jq];} ''
      set -o pipefail
      sh ${bin}/claude-secrets-guard --test | tee $out
    '';
    checks.bin-shellcheck = pkgs.runCommand "bin-shellcheck" {nativeBuildInputs = [pkgs.shellcheck];} ''
      shellcheck -S warning ${lib.concatMapStringsSep " " (s: "${bin}/${s}") scripts}
      touch $out
    '';
  };
}
