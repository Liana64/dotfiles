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

  # taskwarrior must write mutable state (active context, news.version, sync creds)
  # to its taskrc, but the declarative config is a read-only symlink. So the
  # declarative bits live in managed.taskrc and a writable taskrc includes them.
  home.activation.seedTaskrc = lib.hm.dag.entryAfter ["writeBoundary"] ''
    rc="$HOME/.config/task/taskrc"
    if [ ! -f "$rc" ] || [ -L "$rc" ]; then
      mkdir -p "$HOME/.config/task"
      rm -f "$rc"
      echo "include $HOME/.config/task/managed.taskrc" > "$rc"
    fi
  '';
}
