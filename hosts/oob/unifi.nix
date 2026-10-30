{
  hardening,
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) clients;
  set = lib.concatStringsSep ", ";
  mongodb = pkgs.mongodb-ce;
  fcv = "8.3";
in {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) ["unifi" "mongodb-ce"];

  assertions = [
    {
      assertion = lib.versions.majorMinor mongodb.version == fcv;
      message = "mongodb-ce ${mongodb.version} != fcv ${fcv}: step fcv to the next release only, after checking unifi supports it";
    }
  ];

  motd.commands = [[":8443" "UniFi controller"]];

  networking.firewall = {
    allowedTCPPorts = [8080];
    allowedUDPPorts = [3478 10001];
    extraInputRules = ''
      ip saddr { ${set clients.ops} } tcp dport 8443 accept
    '';
  };

  services = {
    unifi = {
      enable = true;
      mongodbPackage = mongodb;
      maximumJavaHeapSize = 768;
    };

    sanoid = {
      enable = true;
      datasets."rpool/var/unifi" = {
        hourly = 48;
        daily = 30;
        monthly = 6;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  systemd.services.unifi-mongodb-fcv = {
    wantedBy = ["unifi.service"];
    after = ["unifi.service"];
    partOf = ["unifi.service"];
    script = ''
      ${lib.getExe pkgs.mongosh} --quiet --port 27117 \
        --eval 'db.adminCommand({setFeatureCompatibilityVersion: "${fcv}", confirm: true})'
    '';
    serviceConfig =
      removeAttrs hardening.confined ["MemoryDenyWriteExecute"]
      // {
        Type = "oneshot";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 30;
        SystemCallErrorNumber = "EPERM";
        IPAddressAllow = "localhost";
        IPAddressDeny = "any";
      };
  };

  systemd.services.sanoid.serviceConfig = hardening.zfs;
}
