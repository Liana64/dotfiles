# @desc: Taskwarrior + nested-task tooling
{...}: {
  flake.modules.homeManager.taskwarrior = {
    pkgs,
    lib,
    inputs,
    ...
  }: let
    taskwarrior-tui = pkgs.taskwarrior-tui.overrideAttrs (_: {
      src = inputs.taskwarrior-tui-src;
      cargoDeps = pkgs.rustPlatform.importCargoLock {
        lockFile = "${inputs.taskwarrior-tui-src}/Cargo.lock";
      };
    });
  in {
    imports = [
      ./_taskwarrior/config.nix
      ./_taskwarrior/hooks.nix
      ./_taskwarrior/reminders.nix
    ];

    home.packages = with pkgs; [
      taskwarrior3
      taskwarrior-tui
      # keep go-task, but invoke as `go-task` so `task` is free for Taskwarrior
      (writeShellScriptBin "go-task" ''exec ${go-task}/bin/task "$@"'')

      # ai-todo <args…> — Taskwarrior against the isolated AI todo store. The three
      # overrides are load-bearing as a unit: omit rc.context=none and the active
      # human context silently hides every AI todo. Baked here so callers (the
      # /todo skill) can never partially apply or misquote them.
      (writeShellScriptBin "ai-todo" ''
        exec ${taskwarrior3}/bin/task \
          rc.data.location="$HOME/Sync/Data/ai-tasks" \
          rc.context=none rc.default.project= "$@"
      '')

      # snooze <id> [when] — defer a task until a wait date (default tomorrow)
      (writeShellScriptBin "task-snooze" ''
        [ -z "$1" ] && { echo "usage: snooze <id> [when]" >&2; exit 1; }
        exec ${taskwarrior3}/bin/task "$1" modify wait:"''${2:-tomorrow}"
      '')

      # subtask <parent-id> <description…> — add a child in the partof tree
      (writeShellScriptBin "subtask" ''
        [ -z "$2" ] && { echo "usage: subtask <parent-id> <description…>" >&2; exit 1; }
        p=$(${taskwarrior3}/bin/task _get "$1".uuid)
        [ -z "$p" ] && { echo "subtask: no such task: $1" >&2; exit 1; }
        proj=$(${taskwarrior3}/bin/task _get "$1".project)
        shift
        exec ${taskwarrior3}/bin/task rc.context=none add partof:"$p" ''${proj:+project:"$proj"} "$@"
      '')

      # workon [<match>|none] — pin a +goal as active (shown in starship). No arg
      # prints the active goal. State file is shared with the prompt/waybar.
      (writeShellScriptBin "workon" ''
        state="$HOME/.local/state/task/active-goal"
        case "$1" in
          "") cat "$state" 2>/dev/null; exit 0 ;;
          none|clear|-c) rm -f "$state"; echo "active goal cleared"; exit 0 ;;
        esac
        match=$(${taskwarrior3}/bin/task rc.context=none status:pending +goal export 2>/dev/null \
          | ${jq}/bin/jq -c --arg q "$*" '[.[] | select((.description|ascii_downcase)|contains($q|ascii_downcase))]')
        n=$(printf '%s' "$match" | ${jq}/bin/jq 'length')
        if [ "$n" -eq 0 ]; then echo "workon: no pending +goal matching: $*" >&2; exit 1; fi
        if [ "$n" -gt 1 ]; then
          echo "workon: multiple goals match:" >&2
          printf '%s' "$match" | ${jq}/bin/jq -r '.[].description' | sed 's/^/  /' >&2
          exit 1
        fi
        desc=$(printf '%s' "$match" | ${jq}/bin/jq -r '.[0].description')
        mkdir -p "$(dirname "$state")"
        printf '%s\n' "$desc" > "$state"
        echo "working on: $desc"
      '')
    ];

    home.sessionVariables.TASKWARRIOR_TUI_DATA = "$HOME/Sync/Data/taskwarrior-tui";
    home.activation.migrateTaskData = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -e "$HOME/.local/share/task/taskchampion.sqlite3" ] && \
         [ ! -e "$HOME/Sync/Data/task/taskchampion.sqlite3" ]; then
        run mkdir -p "$HOME/Sync/Data/task"
        run mv "$HOME/.local/share/task/"taskchampion.sqlite3* "$HOME/Sync/Data/task/"
        run rmdir "$HOME/.local/share/task" 2>/dev/null || true
      fi
    '';

    home.activation.ensureAiTaskStore = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p "$HOME/Sync/Data/ai-tasks"
    '';

    home.activation.seedTaskrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rc="$HOME/.config/task/taskrc"
      if [ ! -f "$rc" ] || [ -L "$rc" ]; then
        mkdir -p "$HOME/.config/task"
        rm -f "$rc"
        echo "include $HOME/.config/task/managed.taskrc" > "$rc"
      fi
    '';
  };
}
