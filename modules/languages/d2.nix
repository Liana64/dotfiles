# @desc: D2 diagrams — helix formatting, build-time SVG renders of every *.d2 in the repo
{lib, ...}: {
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
  };

  flake.modules.homeManager.helix = {
    pkgs,
    lib,
    ...
  }: {
    programs.helix.languages.language = [
      {
        name = "d2";
        scope = "source.d2";
        file-types = ["d2"];
        comment-token = "#";
        formatter = {
          command = lib.getExe pkgs.d2;
          args = ["fmt" "-"];
        };
        auto-format = true;
      }
    ];
  };
}
