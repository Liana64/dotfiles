# @desc: Taskwarrior due/overdue reminders
{
  pkgs,
  hardening,
  ...
}: let
  task = "${pkgs.taskwarrior3}/bin/task";
  jq = "${pkgs.jq}/bin/jq";
  notify = "${pkgs.libnotify}/bin/notify-send";

  # Timed reminders: notify once per task as its due time enters the poll window.
  # Cutoff is computed in shell so taskwarrior gets an unambiguous ISO date.
  dueScript = pkgs.writeShellScript "task-due-reminder" ''
    cutoff=$(${pkgs.coreutils}/bin/date -d 'now + 10 minutes' +%Y-%m-%dT%H:%M:%S)
    ${task} rc.verbose=nothing rc.hooks=off status:pending due.after:now "due.before:$cutoff" export \
      | ${jq} -r '.[] | "\(.description) — due \(.due)"' \
      | while IFS= read -r line; do
          [ -z "$line" ] || ${notify} -u normal -a Taskwarrior "Task due soon" "$line"
        done
  '';
in {
  config = {
    systemd.user.services.task-due-reminder = {
      Unit.Description = "Notify about taskwarrior tasks coming due";
      Service =
        hardening.base
        // {
          Type = "oneshot";
          ExecStart = "${dueScript}";
        };
    };
    systemd.user.timers.task-due-reminder = {
      Unit.Description = "Poll taskwarrior for tasks coming due";
      Timer = {
        OnCalendar = "*:0/10";
        Persistent = false;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
