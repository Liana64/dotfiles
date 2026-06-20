{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    taskwarrior3
    taskwarrior-tui
    # keep go-task, but invoke it as `go-task` so `task` is free for Taskwarrior
    (writeShellScriptBin "go-task" ''exec ${go-task}/bin/task "$@"'')
  ];

  # nix-managed read-only; change settings here, not via `task config`.
  # data.location points straight at the Syncthing dir — no symlink needed.
  xdg.configFile."task/taskrc".text = ''
    data.location=~/Sync/Data/task
    news.version=3.4.2
  '';

  # taskwarrior-tui's own logs/history (separate from the task DB) live there too.
  home.sessionVariables.TASKWARRIOR_TUI_DATA = "$HOME/Sync/Data/taskwarrior-tui";

  # One-time move of an existing store into the Sync location; no-op afterwards.
  home.activation.migrateTaskData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -e "$HOME/.local/share/task/taskchampion.sqlite3" ] && \
       [ ! -e "$HOME/Sync/Data/task/taskchampion.sqlite3" ]; then
      run mkdir -p "$HOME/Sync/Data/task"
      run mv "$HOME/.local/share/task/"taskchampion.sqlite3* "$HOME/Sync/Data/task/"
      run rmdir "$HOME/.local/share/task" 2>/dev/null || true
    fi
  '';
}
