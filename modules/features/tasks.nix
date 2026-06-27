# @desc: taskManager option (nixos) + Todoist app (home)
{...}: {
  flake.modules.nixos.tasks = {lib, ...}: {
    options.taskManager = lib.mkOption {
      type = lib.types.enum ["taskwarrior" "todoist"];
      default = "taskwarrior";
      description = "Task manager surfaced in the bar. Todoist runs as a flatpak either way.";
    };
  };

  flake.modules.homeManager.todoist = {
    pkgs,
    lib,
    osConfig,
    ...
  }: {
    home.packages = lib.mkIf ((osConfig.taskManager or "taskwarrior") == "todoist") [pkgs.todoist];
  };
}
