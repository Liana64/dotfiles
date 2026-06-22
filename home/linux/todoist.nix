{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  home.packages = lib.mkIf ((osConfig.taskManager or "taskwarrior") == "todoist") [pkgs.todoist];
}
