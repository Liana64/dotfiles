# @desc: Module index generator + staleness check (nix run .#gen-index)
{
  inputs,
  lib,
  ...
}: let
  self = inputs.self;
  descOf = path: let
    hit =
      lib.findFirst (l: lib.hasInfix "@desc:" l) null
      (lib.splitString "\n" (builtins.readFile path));
  in
    if hit == null
    then ""
    else lib.trim (lib.elemAt (lib.splitString "@desc:" hit) 1);
  rel = p: lib.removePrefix (toString self + "/") (toString p);
  leaves = dir:
    lib.filter
    (p:
      lib.hasSuffix ".nix" (toString p)
      && baseNameOf (toString p) != "default.nix"
      && !(lib.hasInfix "/_" (rel p)))
    (lib.filesystem.listFilesRecursive dir);
  files = lib.sort (a: b: rel a < rel b) (leaves (self + "/modules"));
  rows = map (p: "| `${rel p}` | ${descOf p} |") files;
  body = lib.concatStringsSep "\n" (["| File | Description |" "| --- | --- |"] ++ rows);
in {
  perSystem = {pkgs, ...}: let
    indexFile = pkgs.writeText "module-index.md" (body + "\n");
  in {
    packages.module-index = indexFile;
    apps.gen-index = {
      type = "app";
      program = toString (pkgs.writeShellScript "gen-index" ''
        set -eu
        target=''${1:-CLAUDE.md}
        ${pkgs.gawk}/bin/awk -v blockfile=${indexFile} '
          BEGIN { while ((getline line < blockfile) > 0) block = block line "\n" }
          /<!-- BEGIN module-index -->/ { print; printf "%s", block; skip=1; next }
          /<!-- END module-index -->/ { skip=0 }
          !skip { print }
        ' "$target" > "$target.tmp" && mv "$target.tmp" "$target"
      '');
    };
    checks.module-index = pkgs.runCommand "check-module-index" {} ''
      ${pkgs.gawk}/bin/awk '/<!-- BEGIN module-index -->/{f=1;next} /<!-- END module-index -->/{f=0} f' \
        ${self}/CLAUDE.md > current
      if diff -u ${indexFile} current; then touch $out; else
        echo "CLAUDE.md module-index is stale; run: nix run .#gen-index" >&2
        exit 1
      fi
    '';
  };
}
