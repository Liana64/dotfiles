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
  theme = "kanagawa";
  impermanence = false;
  nushell = false;
  machineSecrets = true;

  networking.networkmanager.ensureProfiles.profiles = let
    mgmtVlan = id: parent: {
      connection = {
        inherit id;
        type = "vlan";
        interface-name = "${parent}.99";
      };
      vlan = {
        inherit parent;
        id = 99;
      };
      ipv4 = {
        method = "manual";
        address1 = mgmt.cidr.framework;
        never-default = true;
      };
      ipv6.method = "disabled";
    };
  in {
    mgmt = mgmtVlan "mgmt" "enp95s0";
    mgmt-usb = mgmtVlan "mgmt-usb" "enp195s0f0u2";
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_ignore" = 1;
    "net.ipv4.conf.all.arp_announce" = 2;
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
