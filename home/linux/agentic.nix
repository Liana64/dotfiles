{ inputs, lib, pkgs, nixpkgs-unstable, ... }:
let
  systemDir = ../../agentic/system;
  agents = lib.filterAttrs
    (name: type: type == "regular" && lib.hasSuffix ".md" name)
    (builtins.readDir systemDir);
in
{
  programs.claude-code = {
    enable = true;
    package = nixpkgs-unstable.claude-code;
  };

  home.file = {
    ".claude/CLAUDE.md".source = ../../agentic/CLAUDE.md;
  } // lib.mapAttrs'
    (name: _: lib.nameValuePair ".claude/agents/${name}" {
      source = systemDir + "/${name}";
    })
    agents;
}
