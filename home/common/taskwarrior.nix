{ pkgs, lib, colors, ... }:
let
  # "#rrggbb" -> taskwarrior "rgbRGB" 6x6x6 cube code (nearest level).
  # Taskwarrior has no truecolor, so the palette is approximated onto the cube.
  hexToCube = hex:
    let
      h = lib.toLower (lib.removePrefix "#" hex);
      v = c: {
        "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5; "6" = 6; "7" = 7;
        "8" = 8; "9" = 9; "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
      }.${c};
      byte = i: v (builtins.substring i 1 h) * 16 + v (builtins.substring (i + 1) 1 h);
      d = n: if n < 48 then "0" else if n < 115 then "1" else if n < 155 then "2"
             else if n < 195 then "3" else if n < 235 then "4" else "5";
    in "rgb${d (byte 0)}${d (byte 2)}${d (byte 4)}";

  # Populate `goal` (project root) + `subproject` (the rest) from `project`, so
  # taskwarrior-tui can show them as plain columns — it cannot render the
  # project.parent / project.indented formats itself. Runs as add + modify hook.
  goalHook = pkgs.writeShellScript "task-goal-hook" ''
    ${pkgs.coreutils}/bin/tail -n 1 | ${pkgs.jq}/bin/jq -c '
      if (.project // "") != "" then
        (.project | split(".")) as $p
        | .goal = $p[0]
        | .subproject = ($p[1:] | join("."))
      else . end
    '
  '';
in
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
    column.padding=8

    # Goal/subproject are UDAs the hooks populate from `project` — taskwarrior-tui
    # can't render project.parent/.indented, so expose them as plain columns.
    hooks.location=~/.config/task/hooks
    uda.goal.type=string
    uda.goal.label=Goal
    uda.subproject.type=string
    uda.subproject.label=Project
    report.next.columns=id,entry.age,goal,subproject,tags,due.relative,description,urgency
    report.next.labels=ID,Age,Goal,Project,Tags,Due,Description,Urg

    # Theme from the blueberry palette — nearest 256-color cube (no truecolor in taskwarrior).
    color.active=${hexToCube colors.foreground} on ${hexToCube colors.indigo}
    color.overdue=${hexToCube colors.red}
    color.due=${hexToCube colors.orange}
    color.due.today=${hexToCube colors.orange}
    color.scheduled=${hexToCube colors.emerald}
    color.tag.next=${hexToCube colors.lime}
    color.project.none=${hexToCube colors.comment}
    color.completed=${hexToCube colors.comment}
    color.deleted=${hexToCube colors.comment}
    color.label=${hexToCube colors.tan}

    # taskwarrior-tui chrome + layout
    uda.taskwarrior-tui.task-report.info-location=bottom
    uda.taskwarrior-tui.style.report.selection=${hexToCube colors.foreground} on ${hexToCube colors.indigo}
    uda.taskwarrior-tui.selection.bold=yes
    uda.taskwarrior-tui.selection.indicator=•
    uda.taskwarrior-tui.style.context.active=${hexToCube colors.background} on ${hexToCube colors.lime}
    uda.taskwarrior-tui.style.navbar=${hexToCube colors.foreground} on ${hexToCube colors.mbg}
    uda.taskwarrior-tui.style.command=${hexToCube colors.foreground}
    uda.taskwarrior-tui.style.calendar.title=${hexToCube colors.background} on ${hexToCube colors.indigo}
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

  xdg.configFile."task/hooks/on-add-goal".source = goalHook;
  xdg.configFile."task/hooks/on-modify-goal".source = goalHook;
}
