# @desc: Claude Code config: hooks, settings, LSP, materialized agentic/
{...}: {
  flake.modules.homeManager.agentic = {
    lib,
    pkgs,
    nixpkgs-unstable,
    ...
  }: let
    linkMd = srcDir: destDir:
      lib.mapAttrs'
      (name: _: lib.nameValuePair "${destDir}/${name}" {source = srcDir + "/${name}";})
      (lib.filterAttrs
        (name: type: type == "regular" && lib.hasSuffix ".md" name)
        (builtins.readDir srcDir));

    linkSkills = srcDir: destDir:
      lib.mapAttrs'
      (name: _: lib.nameValuePair "${destDir}/${name}" {source = srcDir + "/${name}";})
      (lib.filterAttrs (name: type: type == "directory") (builtins.readDir srcDir));

    claudeScripts = pkgs.symlinkJoin {
      name = "claude-scripts";
      paths = with pkgs; [
        (writeShellScriptBin "claude-secrets-guard"
          (builtins.readFile ../../modules/bin/claude-secrets-guard))
        (writeShellScriptBin "claude-statusline"
          (builtins.readFile ../../modules/bin/claude-statusline))
        (writeShellScriptBin "claude-nix-fmt"
          (builtins.readFile ../../modules/bin/claude-nix-fmt))
        (writeShellScriptBin "dotfiles-verify"
          (builtins.readFile ../../modules/bin/dotfiles-verify))
      ];
      buildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/claude-secrets-guard --prefix PATH : ${pkgs.jq}/bin
        wrapProgram $out/bin/claude-statusline    --prefix PATH : ${pkgs.jq}/bin
        wrapProgram $out/bin/claude-nix-fmt       --prefix PATH : ${lib.makeBinPath [pkgs.jq pkgs.alejandra]}
        wrapProgram $out/bin/dotfiles-verify      --prefix PATH : ${lib.makeBinPath [pkgs.nix pkgs.coreutils]}
      '';
    };
    hardening = import ../../modules/_lib/systemd-hardening.nix;
  in {
    programs.claude-code = {
      enable = true;
      package = nixpkgs-unstable.claude-code;
      # temporarily disabled
      # mcpServers.qdrant-memory = {
      #   type = "sse";
      #   url = "http://qdrant.mcp.milberry.org:8000/sse";
      # };
      #mcpServers.nixos-mcp = {
      #  type = "http";
      #  url = "http://nixos.mcp.milberry.org:8000/mcp";
      #};
      settings = {
        autoMemoryEnabled = true;
        autoDreamEnabled = true;
        teammateDefaultModel = "claude-fable-5";
        alwaysThinkingEnabled = true;
        lspRecommendationDisabled = true;
        env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
        permissions.deny = [
          "Read(.env)"
          "Read(.env.*)"
          "Read(*.tfvars)"
          "Read(*kubeconfig)"
          "Read(**/secrets/**)"
        ];
        lspServers = {
          lua = {
            command = "${pkgs.lua-language-server}/bin/lua-language-server";
            extensionToLanguage = {".lua" = "lua";};
          };
          markdown = {
            command = "${pkgs.marksman}/bin/marksman";
            extensionToLanguage = {".md" = "markdown";};
          };
          nix = {
            command = "${pkgs.nixd}/bin/nixd";
            extensionToLanguage = {".nix" = "nix";};
          };
          rust = {
            command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
            extensionToLanguage = {".rs" = "rust";};
          };
          yaml = {
            command = "${pkgs.yaml-language-server}/bin/yaml-language-server";
            args = ["--stdio"];
            extensionToLanguage = {
              ".yaml" = "yaml";
              ".yml" = "yaml";
            };
          };
        };
        hooks.PreToolUse = [
          {
            matcher = "Read|Edit|MultiEdit|Write|NotebookEdit|Bash";
            hooks = [
              {
                type = "command";
                command = "${claudeScripts}/bin/claude-secrets-guard";
              }
            ];
          }
        ];
        hooks.PostToolUse = [
          {
            matcher = "Edit|MultiEdit|Write";
            hooks = [
              {
                type = "command";
                command = "${claudeScripts}/bin/claude-nix-fmt";
              }
            ];
          }
        ];
        statusLine = {
          type = "command";
          command = "${claudeScripts}/bin/claude-statusline";
        };
      };
    };

    home.file =
      {
        ".claude/CLAUDE.md".source = ./AGENTS.md;
      }
      // linkMd ./agents ".claude/agents"
      // linkSkills ./skills ".claude/skills";

    systemd.user.services.insights-reminder = {
      Unit.Description = "Remind to run /insights in Claude Code";
      Service =
        {
          Type = "oneshot";
          ExecStart = ''${pkgs.libnotify}/bin/notify-send -u normal "Claude Code" "Run /insights to review this month's usage"'';
        }
        // hardening.airgapped;
    };
    systemd.user.timers.insights-reminder = {
      Unit.Description = "Monthly /insights reminder";
      Timer = {
        OnCalendar = "*-*-01 09:07:00";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
