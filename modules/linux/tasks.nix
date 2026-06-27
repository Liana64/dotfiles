# @desc: taskManager option (taskwarrior|todoist) surfaced in the bar
{lib, ...}: {
  options.taskManager = lib.mkOption {
    type = lib.types.enum ["taskwarrior" "todoist"];
    default = "taskwarrior";
    description = "Task manager surfaced in the bar. Todoist runs as a flatpak either way.";
  };
}
