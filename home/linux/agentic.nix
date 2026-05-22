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
    settings = {
      teammateDefaultModel = "opus";
      alwaysThinkingEnabled = true;
      permissions.deny = [
        "Read(./.env)"
        "Read(./.env.*)"
        "Read(./*.tfvars)"
        "Read(./*kubeconfig)"
        "Read(./secrets/**)"
        "Read(./config/credentials.json)"
        "Read(./build)"
      ];
      plugins = [
        "rust-analyzer-lsp@claude-plugins-official"
        "lua-lsp@claude-plugins-official"
      ];
    };
  };

  home.file = {
    ".claude/CLAUDE.md".source = ../../agentic/CLAUDE.md;
    #".claude/.lsp.json".source = ../../agentic/lsp.json;
  } // lib.mapAttrs'
    (name: _: lib.nameValuePair ".claude/agents/${name}" {
      source = systemDir + "/${name}";
    })
    agents;
}
