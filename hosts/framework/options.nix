{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "framework";
  compositor = "sway";
  taskManager = "todoist";
  theme = "milberry";

  users.users.liana.initialHashedPassword = "$y$j9T$kWRrNhfqdXExcsRTmxSIg1$n4jTrwnDRfr814vE2su6d1fELLrVEEaTBoWeSrvqq08";

  services.btrfs.autoScrub = {
    enable = true;
    interval = "Fri *-*-1..7 10:00:00";
  };

  environment.systemPackages = with pkgs; [
    opentofu
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
