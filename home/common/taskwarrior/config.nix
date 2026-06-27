# @desc: Taskwarrior config
{
  lib,
  colors,
  ...
}: let
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
  columns = "due.relative,description,upstream,subproject,tags,entry.age,goal,id";
  labels = "Due,Description,Upstream,Project,Tags,Age,Goal,ID";
in {
  # Change settings here, not via `task config`.
  xdg.configFile."task/managed.taskrc".text = ''
    data.location=~/Sync/Data/task
    news.version=3.4.2
    column.padding=8
    hooks.location=~/.config/task/hooks
    weekstart=monday
    calendar.details=full
    default.project=Inbox
    editor=nvim

    # upstream/subproject: hook-derived from project. goal: manual.
    uda.upstream.type=string
    uda.upstream.label=Upstream
    uda.subproject.type=string
    uda.subproject.label=Project
    uda.goal.type=string
    uda.goal.label=Goal

    # details: long-form body, shown in the detail pane.
    uda.details.type=string
    uda.details.label=Details

    # partof: parent UUID for subtasks (`parent` is reserved).
    uda.partof.type=string
    uda.partof.label=Part of

    # --- Views (Todoist-style reports) ---
    # next = primary view (default.command + tui default), kept populated.
    report.next.columns=${columns}
    report.next.labels=${labels}
    report.next.filter=status:pending +UNBLOCKED partof.none: -goal
    report.next.sort=urgency-

    # Today = overdue + due today; Upcoming = the week ahead.
    report.today.description=Today
    report.today.columns=${columns}
    report.today.labels=${labels}
    report.today.filter=status:pending +UNBLOCKED partof.none: -goal (+OVERDUE or +TODAY)
    report.today.sort=urgency-

    report.upcoming.description=Upcoming
    report.upcoming.columns=${columns}
    report.upcoming.labels=${labels}
    report.upcoming.filter=status:pending partof.none: -goal due.after:today due.before:today+8d
    report.upcoming.sort=due+,urgency-

    report.list.columns=${columns}
    report.list.labels=${labels}
    report.list.filter=status:pending -WAITING -goal

    # Goals: the +goal objective list (own columns).
    report.goals.description=Goals
    report.goals.columns=id,priority,due.relative,description
    report.goals.labels=ID,P,Due,Description
    report.goals.filter=status:pending +goal
    report.goals.sort=due+,priority-

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

    # --- Contexts (one per Todoist project; switch with `c` in taskwarrior-tui) ---
    # write filter auto-files new tasks. -goal hides objectives.
    context.family.read=project:Family -goal
    context.family.write=project:Family
    context.finance.read=project:Finance -goal
    context.finance.write=project:Finance
    context.medical.read=project:Medical -goal
    context.medical.write=project:Medical
    context.organization.read=project:Organization -goal
    context.organization.write=project:Organization
    context.personal.read=project:Personal -goal
    context.personal.write=project:Personal
    context.projects.read=project:Projects -goal
    context.projects.write=project:Projects
    context.rhca.read=project:RHCA -goal
    context.rhca.write=project:RHCA
    context.travel.read=project:Travel -goal
    context.travel.write=project:Travel
    context.wishlist.read=project:Wishlist -goal
    context.wishlist.write=project:Wishlist

    # --- Theme: blueberry palette, nearest 256-color cube (no truecolor) ---
    color.active=${hexToCube colors.foreground} on ${hexToCube colors.highlight}
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
    color.uda.priority.L=${hexToCube colors.highlight}

    # --- taskwarrior-tui chrome + layout ---
    uda.taskwarrior-tui.task-report.info-location=bottom
    uda.taskwarrior-tui.style.report.selection=${hexToCube colors.foreground} on ${hexToCube colors.highlight}
    uda.taskwarrior-tui.selection.bold=yes
    uda.taskwarrior-tui.selection.indicator=•
    uda.taskwarrior-tui.style.context.active=${hexToCube colors.background} on ${hexToCube colors.lime}
    uda.taskwarrior-tui.style.navbar=${hexToCube colors.foreground} on ${hexToCube colors.mbg}
    uda.taskwarrior-tui.style.command=${hexToCube colors.foreground}
    uda.taskwarrior-tui.style.calendar.title=${hexToCube colors.background} on ${hexToCube colors.highlight}

    # enable experimental nested tasks feature
    uda.taskwarrior-tui.nested=true
  '';

  # AI store: same config, AI db, no context. ai-task-tui loads it via --taskrc.
  xdg.configFile."task/ai.taskrc".text = ''
    include ~/.config/task/managed.taskrc
    data.location=~/Sync/Data/ai-tasks
    default.project=
  '';
}
