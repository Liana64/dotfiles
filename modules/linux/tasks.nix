{lib, ...}: {
  options.taskManager = lib.mkOption {
    type = lib.types.enum ["taskwarrior" "todoist"];
    default = "taskwarrior";
    description = "Task manager surfaced in the bar. Todoist runs as a flatpak either way.";
  };
}
