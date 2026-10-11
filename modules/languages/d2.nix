# @desc: D2 diagrams
{lib, ...}: let
  fmt = pkgs:
    pkgs.writeShellApplication {
      name = "d2-fmt";
      runtimeInputs = [pkgs.d2];
      text = ''
        in=$(cat)
        out=$(printf '%s\n' "$in" | d2 fmt -)
        printf '%s\n' "''${out:-$in}"
      '';
    };
in {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    src = lib.fileset.toSource {
      root = ../..;
      fileset = lib.fileset.fileFilter (f: f.hasExt "d2") ../..;
    };
  in {
    packages.diagrams = pkgs.runCommand "diagrams" {nativeBuildInputs = [pkgs.d2];} ''
      cd ${src}
      find . -name '*.d2' | while read -r f; do
        mkdir -p "$out/$(dirname "$f")"
        d2 "$f" "$out/''${f%.d2}.svg"
      done
    '';

    checks.diagrams = config.packages.diagrams;

    checks.d2-fmt = pkgs.runCommand "d2-fmt-check" {nativeBuildInputs = [(fmt pkgs)];} ''
      [ "$(printf 'a -> b\n' | d2-fmt)" = "a -> b" ]
      [ "$(printf 'a->b\n' | d2-fmt)" = "a -> b" ]
      touch $out
    '';
  };

  flake.modules.homeManager.d2 = {pkgs, ...}: {
    home.packages = [pkgs.d2];
    home.shellAliases.d2w = "d2 --watch";
  };

  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix.languages.language = [
      {
        name = "d2";
        scope = "source.d2";
        file-types = ["d2"];
        comment-token = "#";
        formatter.command = lib.getExe (fmt pkgs);
        auto-format = true;
      }
    ];
  };
}
