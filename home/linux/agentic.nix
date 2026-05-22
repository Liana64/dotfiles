{ inputs, lib, pkgs, nixpkgs-unstable, ... }:
let
  systemDir = ../../agentic/system;
  agents = lib.filterAttrs
    (name: type: type == "regular" && lib.hasSuffix ".md" name)
    (builtins.readDir systemDir);

  claudeScripts = pkgs.symlinkJoin {
    name = "claude-scripts";
    paths = with pkgs; [
      (writeShellScriptBin "claude-secrets-guard"
        (builtins.readFile ../../modules/linux/bin/claude-secrets-guard))
      (writeShellScriptBin "claude-statusline"
        (builtins.readFile ../../modules/linux/bin/claude-statusline))
    ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/claude-secrets-guard --prefix PATH : ${pkgs.jq}/bin
      wrapProgram $out/bin/claude-statusline    --prefix PATH : ${pkgs.jq}/bin
    '';
  };
in
{
  programs.claude-code = {
    enable = true;
    package = nixpkgs-unstable.claude-code;
    settings = {
      teammateDefaultModel = "opus";
      alwaysThinkingEnabled = true;
      env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
      permissions.deny = [
        "Read(./.env)"
        "Read(./.env.*)"
        "Read(./*.tfvars)"
        "Read(./*kubeconfig)"
        "Read(./secrets/**)"
        "Read(./config/credentials.json)"
        "Read(./build)"
      ];
      lspServers = {
        lua = {
          command = "${pkgs.lua-language-server}/bin/lua-language-server";
          extensionToLanguage = { ".lua" = "lua"; };
        };
        markdown = {
          command = "${pkgs.marksman}/bin/marksman";
          extensionToLanguage = { ".md" = "markdown"; };
        };
        nix = {
          command = "${pkgs.nil}/bin/nil";
          extensionToLanguage = { ".nix" = "nix"; };
        };
        rust = {
          command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          extensionToLanguage = { ".rs" = "rust"; };
        };
        yaml = {
          command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
          args = [ "--stdio" ];
          extensionToLanguage = { ".yaml" = "yaml"; ".yml" = "yaml"; };
        };
      };
      hooks.PreToolUse = [
        {
          matcher = "Read|Edit|MultiEdit|Write|NotebookEdit|Bash";
          hooks = [
            { type = "command"; command = "${claudeScripts}/bin/claude-secrets-guard"; }
          ];
        }
      ];
      statusLine = {
        type = "command";
        command = "${claudeScripts}/bin/claude-statusline";
      };
    };
  };

  home.file = {
    ".claude/CLAUDE.md".source = ../../agentic/AGENTS.md;
  } // lib.mapAttrs'
    (name: _: lib.nameValuePair ".claude/agents/${name}" {
      source = systemDir + "/${name}";
    })
    agents;
}
