{
  # inputs,
  pkgs,
  ...
}: {
  imports = [
    # inputs.disko.nixosModules.disko
    # ./disko.nix
    ./cache.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "framework";
  taskManager = "todoist";
  theme = "kanagawa";
  impermanence = false;
  nushell = false;
  machineSecrets = true;

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
