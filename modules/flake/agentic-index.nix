# @desc: Agentic map table generator + staleness check (nix run .#gen-agentic-index)
{
  inputs,
  lib,
  ...
}: let
  inherit (inputs) self;
  descOf = path: let
    hit =
      lib.findFirst (l: lib.hasInfix "@desc:" l) null
      (lib.splitString "\n" (builtins.readFile path));
  in
    if hit == null
    then ""
    else lib.trim (lib.elemAt (lib.splitString "@desc:" hit) 1);
  frontDesc = path: let
    hit =
      lib.findFirst (l: lib.hasPrefix "description:" l) null
      (lib.splitString "\n" (builtins.readFile path));
  in
    if hit == null
    then ""
    else lib.trim (lib.removePrefix "description:" hit);
  table = rows:
    lib.concatStringsSep "\n"
    (["| Name | Description |" "| --- | --- |"] ++ rows);

  skillsDir = self + "/modules/agentic/skills";
  agentsDir = self + "/modules/agentic/agents";
  binDir = self + "/modules/bin";

  blocks = {
    agentic-skills = table (lib.mapAttrsToList
      (name: _: "| `/${name}` | ${frontDesc (skillsDir + "/${name}/SKILL.md")} |")
      (lib.filterAttrs (_: type: type == "directory") (builtins.readDir skillsDir)));
    agentic-agents = table (lib.mapAttrsToList
      (name: _: "| `${lib.removeSuffix ".md" name}` | ${frontDesc (agentsDir + "/${name}")} |")
      (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".md" name)
        (builtins.readDir agentsDir)));
    agentic-scripts = table (lib.mapAttrsToList
      (name: _: "| `${name}` | ${descOf (binDir + "/${name}")} |")
      (lib.filterAttrs
        (name: type: type == "regular" && lib.hasInfix "@desc:" (builtins.readFile (binDir + "/${name}")))
        (builtins.readDir binDir)));
  };
in {
  perSystem = {pkgs, ...}: let
    blockFiles = lib.mapAttrs (name: body: pkgs.writeText "${name}.md" (body + "\n")) blocks;
  in {
    apps.gen-agentic-index = {
      type = "app";
      program = toString (pkgs.writeShellScript "gen-agentic-index" ''
        set -eu
        target=''${1:-modules/agentic/AGENTIC.md}
        ${lib.concatStrings (lib.mapAttrsToList (name: file: ''
            ${pkgs.gawk}/bin/awk -v blockfile=${file} '
              BEGIN { while ((getline line < blockfile) > 0) block = block line "\n" }
              /<!-- BEGIN ${name} -->/ { print; printf "%s", block; skip=1; next }
              /<!-- END ${name} -->/ { skip=0 }
              !skip { print }
            ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
          '')
          blockFiles)}
      '');
    };
    checks.agentic-index = pkgs.runCommand "check-agentic-index" {} (
      lib.concatStrings (lib.mapAttrsToList (name: file: ''
          ${pkgs.gawk}/bin/awk '/<!-- BEGIN ${name} -->/{f=1;next} /<!-- END ${name} -->/{f=0} f' \
            ${self}/modules/agentic/AGENTIC.md > current
          if ! diff -u ${file} current; then
            echo "AGENTIC.md ${name} is stale; run: nix run .#gen-agentic-index" >&2
            exit 1
          fi
        '')
        blockFiles)
      + "touch $out"
    );
  };
}
