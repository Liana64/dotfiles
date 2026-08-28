{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "framework";
  compositor = "sway";
  taskManager = "todoist";
  theme = "kanagawa";
  impermanence = false;
  nushell = false;

  sops.secrets."users/liana/password".neededForUsers = true;
  users.mutableUsers = false;
  users.users.liana.hashedPasswordFile = config.sops.secrets."users/liana/password".path;

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
