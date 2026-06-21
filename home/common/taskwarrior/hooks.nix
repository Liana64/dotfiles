{pkgs, ...}: let
  task = "${pkgs.taskwarrior3}/bin/task";
  jq = "${pkgs.jq}/bin/jq";
  # add + modify hook: derive upstream/subproject, guard partof cycles, block completing tasks with open subtasks.
  treeHook = pkgs.writeShellScript "task-tree-hook" ''
    data=""
    for a in "$@"; do case "$a" in data:*) data="''${a#data:}";; esac; done
    TASK="${task} rc.data.location=$data rc.hooks=off rc.verbose=nothing rc.confirmation=off"

    IFS= read -r l1 || exit 0
    if IFS= read -r l2; then old="$l1"; new="$l2"; else new="$l1"; fi

    uuid=$(printf '%s' "$new" | ${jq} -r '.uuid // empty')
    partof=$(printf '%s' "$new" | ${jq} -r '.partof // empty')
    status=$(printf '%s' "$new" | ${jq} -r '.status // empty')

    # Cycle guard: walk up the partof chain; reject if it loops back to uuid.
    if [ -n "$partof" ]; then
      node="$partof"; seen=""
      while [ -n "$node" ]; do
        [ "$node" = "$uuid" ] && { echo "subtask: would create a cycle"; exit 1; }
        case "$seen" in *" $node "*) break;; esac
        seen="$seen $node "
        node=$($TASK _get "$node".partof 2>/dev/null)
      done
    fi

    # Block completing a task that still has open subtasks.
    if [ "$status" = "completed" ]; then
      oldstatus=$(printf '%s' "$old" | ${jq} -r '.status // empty')
      if [ "$oldstatus" != "completed" ]; then
        kids=$($TASK status:pending partof:"$uuid" count 2>/dev/null)
        [ "''${kids:-0}" -gt 0 ] 2>/dev/null && { echo "task has $kids open subtask(s); finish them first"; exit 1; }
      fi
    fi

    printf '%s' "$new" | ${jq} -c '
      if (.project // "") != "" then
        (.project | split(".")) as $p
        | .upstream = $p[0]
        | .subproject = ($p[1:] | join("."))
      else . end
    '
  '';
in {
  xdg.configFile."task/hooks/on-add-tree".source = treeHook;
  xdg.configFile."task/hooks/on-modify-tree".source = treeHook;
}
