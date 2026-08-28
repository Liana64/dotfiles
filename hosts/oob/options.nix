{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./secrets.nix
    ./unifi.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";

  boot = {
    loader.generic-extlinux-compatible.enable = true;
    supportedFilesystems = ["zfs"];
    zfs.devNodes = "/dev/disk/by-id";
    zfs.forceImportRoot = false;
    # 4G-model floor — leave ram to mongod + java
    kernelParams = ["zfs.zfs_arc_max=${toString (1024 * 1024 * 1024)}"];
  };

  networking = {
    hostName = "oob";
    hostId = "b28118b6";
    useDHCP = false;
    useNetworkd = true;
    firewall.allowedTCPPorts = [22];
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "ipv4";
  };

  zramSwap.enable = true;

  nix.registry.nixpkgs.to = lib.mkForce {
    type = "path";
    path = inputs.nixpkgs-unstable.outPath;
  };

  services = {
    resolved.enable = true;
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
    zfs.trim.enable = true;
  };

  users.users.liana = {
    uid = 1000;
    openssh.authorizedKeys.keys = [(import ../../modules/_lib/keys.nix).liana];
  };

  system.stateVersion = "26.05";
}
