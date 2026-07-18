# @desc: Todoist due/overdue reminders (taskManager = todoist)
{...}: {
  flake.modules.homeManager.todoist = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    hardening = import ../../_lib/systemd-hardening.nix;
    todoist = "${pkgs.todoist}/bin/todoist";
    jq = "${pkgs.jq}/bin/jq";
    notify = "${pkgs.libnotify}/bin/notify-send";
    bin = "${pkgs.coreutils}/bin";

    # no token, exit before the cli opens its interactive prompt
    sync = ''
      [ -f "$HOME/.config/todoist/config.json" ] || exit 0
      ${todoist} sync >/dev/null 2>&1 || true
      cache="$HOME/.cache/todoist/cache.json"
      [ -f "$cache" ] || exit 0
    '';

    # only timed dues fire the 10-min window, all-day dues wait for the digest
    dueScript = pkgs.writeShellScript "task-due-reminder" ''
      ${sync}
      now=$(${bin}/date +%s)
      cutoff=$((now + 600))
      tab=$(printf '\t')
      ${jq} -r '(.user.id|tostring) as $me | .items[]
        | select(.checked != true)
        | select(.responsible_uid == null or (.responsible_uid|tostring) == $me)
        | select(.due != null and ((.due.date // "") | test("T")))
        | "\(.due.date)\t\(.content)"' "$cache" 2>/dev/null \
        | while IFS="$tab" read -r due content; do
            t=$(${bin}/date -d "$due" +%s 2>/dev/null) || continue
            [ "$t" -gt "$now" ] && [ "$t" -lt "$cutoff" ] || continue
            ${notify} -u normal -a Todoist "Task due soon" "$content"
          done
    '';

    # the CLI filter grammar has no assignee predicate, drop items assigned to
    # someone else via the sync cache (responsible_uid: null = mine)
    digestScript = pkgs.writeShellScript "task-daily-digest" ''
      ${sync}
      others=$(${jq} -r '(.user.id|tostring) as $me | .items[]
        | select(.responsible_uid != null and (.responsible_uid|tostring) != $me) | .id' "$cache" 2>/dev/null)
      list() {
        { printf '%s\n' "$others"; echo "==="; ${todoist} --csv list --filter "$1" 2>/dev/null; } \
          | ${pkgs.gawk}/bin/awk -F, '
              $0=="===" { body=1; next }
              !body { if ($0 != "") excl[$0]=1; next }
              !($1 in excl) { print }' \
          | ${bin}/cut -d, -f6- | ${pkgs.gnused}/bin/sed 's/^"//; s/"$//; s/^/• /'
      }
      body=$(list "overdue & !today"; list "today")
      [ -z "$body" ] && exit 0
      n=$(printf '%s\n' "$body" | ${bin}/wc -l)
      ${notify} -u normal -a Todoist "$n task(s) today" "$body"
    '';
  in {
    # unit names are shared with the taskwarrior twin in shell/_taskwarrior/reminders.nix
    config = lib.mkIf ((osConfig.taskManager or "taskwarrior") == "todoist") {
      systemd.user.services.task-due-reminder = {
        Unit.Description = "Notify about todoist tasks coming due";
        Service =
          hardening.base
          // {
            Type = "oneshot";
            ExecStart = "${dueScript}";
          };
      };
      systemd.user.timers.task-due-reminder = {
        Unit.Description = "Poll todoist for tasks coming due";
        Timer = {
          OnCalendar = "*:0/10";
          Persistent = false;
        };
        Install.WantedBy = ["timers.target"];
      };

      systemd.user.services.task-daily-digest = {
        Unit.Description = "Morning todoist agenda notification";
        Service =
          hardening.base
          // {
            Type = "oneshot";
            ExecStart = "${digestScript}";
          };
      };
      systemd.user.timers.task-daily-digest = {
        Unit.Description = "Daily todoist agenda digest";
        Timer = {
          OnCalendar = "*-*-* 08:00:00";
          Persistent = true;
        };
        Install.WantedBy = ["timers.target"];
      };
    };
  };
}
