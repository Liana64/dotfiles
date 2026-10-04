{
  config,
  lib,
  hardening,
  ...
}: let
  sync = import ../../modules/_lib/syncthing.nix;
  self = config.networking.hostName;
  secret = name: config.sops.secrets."syncthing/${name}".path;
  folders = lib.filterAttrs (_: f: lib.elem self f.devices) sync.folders;
  peers = lib.remove self (lib.unique (lib.concatMap (f: f.devices) (lib.attrValues folders)));
in {
  sops.secrets = lib.genAttrs ["syncthing/cert" "syncthing/key" "syncthing/gui-password"] (_: {owner = "syncthing";});

  services.syncthing = {
    enable = true;
    cert = secret "cert";
    key = secret "key";
    guiPasswordFile = secret "gui-password";
    guiAddress = "127.0.0.1:8384";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      gui.user = "admin";
      options = {
        listenAddresses = sync.devices.${self}.addresses;
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
      devices = lib.getAttrs peers sync.devices;
      folders =
        lib.mapAttrs (_: f: {
          inherit (f) label;
          path = "/tank/users/sync/${f.owner}/${baseNameOf f.path}";
          devices = lib.remove self f.devices;
          inherit (sync) versioning;
        })
        folders;
    };
  };

  systemd.services.syncthing = {
    requires = ["zfs-datasets.service"];
    after = ["zfs-datasets.service"];
    serviceConfig =
      hardening.confined
      // {
        SystemCallFilter = ["@system-service" "~@privileged"];
        ReadWritePaths = ["/tank/users/sync" config.services.syncthing.dataDir];
      };
  };

  networking.firewall.interfaces.hstore.allowedTCPPorts = [22000];
}
