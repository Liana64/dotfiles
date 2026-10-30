{
  lib,
  pkgs,
  ...
}: let
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

  networking.firewall = {
    allowedTCPPorts = [8080 8443];
    allowedUDPPorts = [3478 10001];
  };

  services = {
    unifi = {
      enable = true;
      mongodbPackage = mongodb;
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
    serviceConfig = {
      Type = "oneshot";
      DynamicUser = true;
      Restart = "on-failure";
      RestartSec = 30;
      IPAddressAllow = "localhost";
      IPAddressDeny = "any";
    };
  };
}
