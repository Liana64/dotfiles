{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./config.nix
    ./hooks.nix
    ./reminders.nix
  ];

  home.packages = with pkgs; [
    taskwarrior3
    taskwarrior-tui
    # keep go-task, but invoke it as `go-task` so `task` is free for Taskwarrior
    (writeShellScriptBin "go-task" ''exec ${go-task}/bin/task "$@"'')
    # snooze <id> [when] — defer a task until a wait date (default tomorrow)
    (writeShellScriptBin "task-snooze" ''
      [ -z "$1" ] && { echo "usage: snooze <id> [when]" >&2; exit 1; }
      exec ${taskwarrior3}/bin/task "$1" modify wait:"''${2:-tomorrow}"
    '')
    # subtask <parent-id> <description…> — add a child in the partof tree,
    # inheriting the parent's project.
    (writeShellScriptBin "subtask" ''
      [ -z "$2" ] && { echo "usage: subtask <parent-id> <description…>" >&2; exit 1; }
      p=$(${taskwarrior3}/bin/task _get "$1".uuid)
      [ -z "$p" ] && { echo "subtask: no such task: $1" >&2; exit 1; }
      proj=$(${taskwarrior3}/bin/task _get "$1".project)
      shift
      exec ${taskwarrior3}/bin/task rc.context=none add partof:"$p" ''${proj:+project:"$proj"} "$@"
    '')
  ];

  # taskwarrior-tui's own logs/history (separate from the task DB) live there too.
  home.sessionVariables.TASKWARRIOR_TUI_DATA = "$HOME/Sync/Data/taskwarrior-tui";

  # One-time move of an existing store into the Sync location; no-op afterwards.
  home.activation.migrateTaskData = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ -e "$HOME/.local/share/task/taskchampion.sqlite3" ] && \
       [ ! -e "$HOME/Sync/Data/task/taskchampion.sqlite3" ]; then
      run mkdir -p "$HOME/Sync/Data/task"
      run mv "$HOME/.local/share/task/"taskchampion.sqlite3* "$HOME/Sync/Data/task/"
      run rmdir "$HOME/.local/share/task" 2>/dev/null || true
    fi
  '';

  # Dedicated AI task store (the /todo skill's rc.data.location). Ensure it exists.
  home.activation.ensureAiTaskStore = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "$HOME/Sync/Data/ai-tasks"
  '';

  # Writable taskrc including managed.taskrc — taskwarrior must write context/sync state.
  home.activation.seedTaskrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rc="$HOME/.config/task/taskrc"
    if [ ! -f "$rc" ] || [ -L "$rc" ]; then
      mkdir -p "$HOME/.config/task"
      rm -f "$rc"
      echo "include $HOME/.config/task/managed.taskrc" > "$rc"
    fi
  '';
}
