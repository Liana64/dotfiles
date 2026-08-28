{pkgs, ...}: {
  networking.firewall = {
    allowedTCPPorts = [8080 8443];
    allowedUDPPorts = [3478 10001];
  };

  services = {
    unifi = {
      enable = true;
      mongodbPackage = pkgs.mongodb-ce;
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
}
