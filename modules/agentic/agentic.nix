# @desc: Claude Code config: hooks, settings, LSP, materialized agentic/
{...}: {
  flake.modules.homeManager.agentic = {
    lib,
    pkgs,
    nixpkgs-unstable,
    ...
  }: let
    link = pred: srcDir: destDir:
      lib.mapAttrs'
      (name: _: lib.nameValuePair "${destDir}/${name}" {source = srcDir + "/${name}";})
      (lib.filterAttrs pred (builtins.readDir srcDir));

    # script in ../bin = its runtime PATH deps
    scripts = with pkgs; {
      ai-memory = [git gnugrep gawk findutils coreutils];
      claude-comment-check = [jq coreutils];
      claude-nix-check = [jq alejandra statix deadnix];
      claude-secrets-guard = [jq];
      claude-skill-guard = [jq];
      claude-statusline = [jq];
      dotfiles-verify = [nix git coreutils];
      hardening-probe = [systemd coreutils gnused gnugrep jq nix];
    };
    claudeScripts = pkgs.symlinkJoin {
      name = "claude-scripts";
      paths =
        lib.mapAttrsToList
        (name: _: pkgs.writeShellScriptBin name (builtins.readFile (../bin + "/${name}")))
        scripts;
      buildInputs = [pkgs.makeWrapper];
      postBuild =
        lib.concatStrings
        (lib.mapAttrsToList
          (name: deps: "wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath deps}\n")
          scripts)
        + ''
          wrapProgram $out/bin/hardening-probe \
            --set HARDENING_BASE ${lib.escapeShellArg (toProps hardening.base)} \
            --set HARDENING_CONFINED ${lib.escapeShellArg (toProps hardening.confined)} \
            --set HARDENING_AIRGAPPED ${lib.escapeShellArg (toProps hardening.airgapped)}
          wrapProgram $out/bin/claude-secrets-guard \
            --set CLAUDE_SECRET_GLOBS ${lib.escapeShellArg (lib.concatStringsSep " " secretPatterns.globs)} \
            --set CLAUDE_SECRET_DIRS ${lib.escapeShellArg (lib.concatStringsSep " " secretPatterns.dirs)}
          wrapProgram $out/bin/claude-skill-guard \
            --set CLAUDE_DENIED_SKILLS code-review
          wrapProgram $out/bin/claude-comment-check \
            --set CLAUDE_SECRET_GLOBS ${lib.escapeShellArg (lib.concatStringsSep " " secretPatterns.globs)} \
            --set CLAUDE_SECRET_DIRS ${lib.escapeShellArg (lib.concatStringsSep " " secretPatterns.dirs)}
        '';
    };

    # Deny pre-empts hooks and reaches file tools outside the hook matcher
    # (Grep, Glob); the guard hook gets the same lists injected at wrap time.
    secretPatterns = import ../_lib/secret-patterns.nix;

    hardening = import ../_lib/systemd-hardening.nix;
    # one systemd-run property line per attr; list attrs get a line per element
    toProps = preset:
      lib.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList
        (k: v:
          if lib.isList v
          then map (x: "${k}=${toString x}") v
          else "${k}=${
            if lib.isBool v
            then lib.boolToString v
            else toString v
          }")
        preset));
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
        # registers the Agent-tool "fork" subagent type (/dream evidence base);
        # not on by default in 2.1.197 despite the /fork command being enabled
        env.CLAUDE_CODE_FORK_SUBAGENT = "1";
        permissions.deny =
          map (g: "Read(${g})") secretPatterns.globs
          ++ lib.concatMap (d: ["Read(**/${d}/**)" "Read(~/${d}/**)"]) secretPatterns.dirs;
        # Wildcards only on binaries with no eval/exec flags plus own scripts;
        # evaluators (nix eval/build, cargo, nix fmt with args) stay prompted.
        # Compound commands decompose: every segment must match a rule.
        permissions.allow = [
          "Bash(ai-memory *)"
          "Bash(ai-todo *)"
          "Bash(boltctl domains *)"
          "Bash(boltctl list *)"
          "Bash(dmesg)"
          "Bash(dotfiles-verify)"
          "Bash(dotfiles-verify *)"
          "Bash(git add *)"
          "Bash(journalctl *)"
          "Bash(kubectl get *)"
          "Bash(lsmod)"
          "Bash(lspci *)"
          "Bash(lsusb *)"
          "Bash(modinfo *)"
          "Bash(nix flake check)"
          "Bash(nix flake metadata)"
          "Bash(nix flake show)"
          "Bash(nix fmt)"
          "Bash(nix run .#gen-agentic-index)"
          "Bash(nix run .#gen-index)"
          "Bash(systemctl --user is-enabled *)"
          "Bash(systemctl --user list-unit-files *)"
          "Bash(systemctl --user show *)"
          "Bash(systemctl --user status *)"
          "Bash(systemctl status *)"
          "Read(~/Projects/Software/ai-memory/**)"
          "Read(~/.claude/projects/**/memory/**)"
          "Skill"
          "WebFetch(domain:www.anthropic.com)"
          "WebSearch"
        ];
        lspServers = {
          bash = {
            command = "${pkgs.bash-language-server}/bin/bash-language-server";
            args = ["start"];
            extensionToLanguage = {
              ".bash" = "shellscript";
              ".sh" = "shellscript";
            };
          };
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
          {
            matcher = "Skill";
            hooks = [
              {
                type = "command";
                command = "${claudeScripts}/bin/claude-skill-guard";
              }
            ];
          }
          {
            # pre-image snapshot so the PostToolUse leg flags only net-new comments
            matcher = "Edit|MultiEdit|Write|NotebookEdit";
            hooks = [
              {
                type = "command";
                command = "${claudeScripts}/bin/claude-comment-check";
              }
            ];
          }
        ];
        hooks.PostToolUse = [
          {
            matcher = "Edit|Write";
            hooks = [
              {
                type = "command";
                command = "${claudeScripts}/bin/claude-nix-check";
              }
            ];
          }
          {
            matcher = "Edit|MultiEdit|Write|NotebookEdit";
            hooks = [
              {
                type = "command";
                command = "${claudeScripts}/bin/claude-comment-check";
              }
            ];
          }
        ];
        hooks.SessionStart = [
          {
            matcher = "startup|resume";
            hooks = [
              {
                type = "command";
                # pull backgrounded: session start must not wait on the network;
                # debt whispers one line only when the dream loop is stale
                # (guarded: a fresh host without the store must not error every start)
                command = "(${claudeScripts}/bin/ai-memory pull >/dev/null 2>&1 &); ${claudeScripts}/bin/ai-memory debt 2>/dev/null || true";
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

    home.packages = [claudeScripts];

    home.file =
      {
        ".claude/CLAUDE.md".source = ./AGENTS.md;
      }
      // link (name: type: type == "regular" && lib.hasSuffix ".md" name) ./agents ".claude/agents"
      // link (_: type: type == "directory") ./skills ".claude/skills";

    systemd.user.services.insights-reminder = {
      Unit.Description = "Remind to run /insights in Claude Code";
      Service =
        {
          Type = "oneshot";
          ExecStart = ''${pkgs.libnotify}/bin/notify-send -u normal "Claude Code" "Run /insights to review this month's usage"'';
        }
        // hardening.airgapped
        // {
          # ProtectHome hides /run/user with it, severing the session bus;
          # tmpfs + bind exposes only the socket (verified: hardening-probe)
          ProtectHome = "tmpfs";
          BindPaths = ["%t/bus"];
        };
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
