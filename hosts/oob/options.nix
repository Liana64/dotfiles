{
  hardening,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) mgmt clients;
  set = lib.concatStringsSep ", ";
  zfsJob = hardening.zfs // {CapabilityBoundingSet = "CAP_SYS_ADMIN";};
in {
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    inputs.disko.nixosModules.disko
    ./backup.nix
    ./disko.nix
    ./monitoring.nix
    ./nut.nix
    ./unifi.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  boot = {
    kernelPackages = pkgs.linuxPackages;
    loader.generic-extlinux-compatible.enable = true;
    supportedFilesystems = ["zfs"];
    zfs.devNodes = "/dev/disk/by-id";
    zfs.forceImportRoot = false;
    # 4G-model floor — leave ram to mongod + java
    kernelParams = ["zfs.zfs_arc_max=${toString (1024 * 1024 * 1024)}"];
  };

  motd.description = "out-of-band: UniFi and UPS";

  networking = {
    hostName = "oob";
    hostId = "b28118b6";
    useDHCP = false;
    useNetworkd = true;
    nftables.enable = true;
    firewall.extraInputRules = ''
      ip saddr { ${set clients.liana} } tcp dport 22 accept
    '';
  };

  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    address = [mgmt.cidr.oob];
    gateway = [mgmt.gateway];
    dns = [mgmt.gateway];
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
        AllowUsers = ["liana"];
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthOptions = "verify-required";
      };
    };
    zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
    zfs.trim.enable = true;
  };

  systemd.services = {
    zfs-scrub.serviceConfig = zfsJob;
    zpool-trim.serviceConfig = zfsJob;
    zfs-zed.serviceConfig = zfsJob;
  };

  users.users.liana = {
    uid = 1000;
    openssh.authorizedKeys.keys = inputs.self.keys.liana;
  };

  system.stateVersion = "26.05";
}
