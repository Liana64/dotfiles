{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) mgmt;
in {
  imports = [
    # inputs.disko.nixosModules.disko
    # ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "framework";
  taskManager = "todoist";
  theme = "kanagawa";
  impermanence = false;
  nushell = false;
  machineSecrets = true;

  networking.networkmanager.ensureProfiles.profiles.mgmt = {
    connection = {
      id = "mgmt";
      type = "vlan";
      interface-name = "enp95s0.99";
    };
    vlan = {
      parent = "enp95s0";
      id = 99;
    };
    ipv4 = {
      method = "manual";
      address1 = mgmt.cidr.framework;
      never-default = true;
    };
    ipv6.method = "disabled";
  };

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
