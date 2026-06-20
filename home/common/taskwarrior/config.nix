{
  lib,
  colors,
  ...
}: let
  # "#rrggbb" -> taskwarrior "rgbRGB" 6x6x6 cube code (nearest level).
  # Taskwarrior has no truecolor, so the palette is approximated onto the cube.
  hexToCube = hex: let
    h = lib.toLower (lib.removePrefix "#" hex);
    v = c:
      {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "a" = 10;
        "b" = 11;
        "c" = 12;
        "d" = 13;
        "e" = 14;
        "f" = 15;
      }.${
        c
      };
    byte = i: v (builtins.substring i 1 h) * 16 + v (builtins.substring (i + 1) 1 h);
    d = n:
      if n < 48
      then "0"
      else if n < 115
      then "1"
      else if n < 155
      then "2"
      else if n < 195
      then "3"
      else if n < 235
      then "4"
      else "5";
  in "rgb${d (byte 0)}${d (byte 2)}${d (byte 4)}";
in {
  # Declarative config, read-only — included from a writable ~/.config/task/taskrc
  # (seeded in default.nix) so taskwarrior can persist mutable state: active context,
  # news.version, sync creds. Change settings here, not via `task config`.
  xdg.configFile."task/managed.taskrc".text = ''
    data.location=~/Sync/Data/task
    news.version=3.4.2
    column.padding=8
    hooks.location=~/.config/task/hooks
    weekstart=monday
    calendar.details=full
    default.project=Inbox

    # Goal/subproject are UDAs the hooks populate from `project` — taskwarrior-tui
    # can't render project.parent/.indented, so expose them as plain columns.
    uda.goal.type=string
    uda.goal.label=Upstream
    uda.subproject.type=string
    uda.subproject.label=Project

    # --- Views (Todoist-style reports) ---
    # `goal` (Upstream) sits to the right of description; blocked tasks hidden.
    report.next.columns=id,entry.age,subproject,tags,due.relative,description,goal
    report.next.labels=ID,Age,Project,Tags,Due,Description,Upstream
    report.next.filter=status:pending +UNBLOCKED

    # Today = overdue + due today; Upcoming = the week ahead.
    report.today.description=Today
    report.today.columns=id,subproject,tags,priority,due.relative,description,goal
    report.today.labels=ID,Project,Tags,P,Due,Description,Upstream
    report.today.filter=status:pending +UNBLOCKED (+OVERDUE or +TODAY)
    report.today.sort=urgency-

    report.upcoming.description=Upcoming
    report.upcoming.columns=id,subproject,tags,priority,due.relative,description,goal
    report.upcoming.labels=ID,Project,Tags,P,Due,Description,Upstream
    report.upcoming.filter=status:pending due.after:today due.before:today+8d
    report.upcoming.sort=due+,urgency-

    # Goal rollup — keeps Upstream first since it's the grouping/sort key.
    report.goals.description=Goals
    report.goals.columns=goal,subproject,priority,due.relative,description
    report.goals.labels=Upstream,Project,P,Due,Description
    report.goals.filter=status:pending
    report.goals.sort=goal+,urgency-

    # Dependency navigation — depends.list surfaces the blocking task IDs.
    report.blocked.description=Blocked tasks
    report.blocked.columns=id,depends.list,subproject,due.relative,description
    report.blocked.labels=ID,Blocked by,Project,Due,Description
    report.blocked.filter=status:pending +BLOCKED
    report.blocked.sort=urgency-

    report.blocking.description=Blocking tasks
    report.blocking.columns=id,subproject,due.relative,description
    report.blocking.labels=ID,Project,Due,Description
    report.blocking.filter=status:pending +BLOCKING
    report.blocking.sort=urgency-

    # --- Contexts (project selectors — switch with `c` in taskwarrior-tui) ---
    # Areas are project roots; switching a context also auto-files new tasks into
    # that project. Loose captures fall to Inbox via default.project.
    context.home.read=project:Home
    context.home.write=project:Home
    context.lab.read=project:Lab
    context.lab.write=project:Lab
    context.inbox.read=project:Inbox
    context.inbox.write=project:Inbox

    # --- Theme: blueberry palette, nearest 256-color cube (no truecolor) ---
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
    # Priority palette = Todoist P1/P2/P3 (P4 = unset, no color).
    color.uda.priority.H=${hexToCube colors.red}
    color.uda.priority.M=${hexToCube colors.orange}
    color.uda.priority.L=${hexToCube colors.indigo}

    # --- taskwarrior-tui chrome + layout ---
    uda.taskwarrior-tui.task-report.info-location=bottom
    uda.taskwarrior-tui.style.report.selection=${hexToCube colors.foreground} on ${hexToCube colors.indigo}
    uda.taskwarrior-tui.selection.bold=yes
    uda.taskwarrior-tui.selection.indicator=•
    uda.taskwarrior-tui.style.context.active=${hexToCube colors.background} on ${hexToCube colors.lime}
    uda.taskwarrior-tui.style.navbar=${hexToCube colors.foreground} on ${hexToCube colors.mbg}
    uda.taskwarrior-tui.style.command=${hexToCube colors.foreground}
    uda.taskwarrior-tui.style.calendar.title=${hexToCube colors.background} on ${hexToCube colors.indigo}
  '';
}
