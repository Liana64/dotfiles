{ pkgs, ... }:
{
  home.packages = [ pkgs.protonmail-bridge ];
  systemd.user.services.protonmail-bridge = {
    Unit = {
      Description = "Protonmail Bridge";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  services.gnome-keyring.enable = true;
}
