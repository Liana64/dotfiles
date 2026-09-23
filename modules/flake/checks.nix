# @desc: Flake checks: shellcheck over modules/bin
{lib, ...}: {
  perSystem = {pkgs, ...}: let
    bin = ../bin;
    scripts = lib.attrNames (lib.filterAttrs (name: type: type == "regular" && !lib.hasSuffix ".md" name) (builtins.readDir bin));
  in {
    checks.bin-shellcheck = pkgs.runCommand "bin-shellcheck" {nativeBuildInputs = [pkgs.shellcheck];} ''
      shellcheck -S warning ${lib.concatMapStringsSep " " (s: "${bin}/${s}") scripts}
      touch $out
    '';
  };
}
