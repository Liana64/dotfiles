{
  inputs,
  pkgs,
  ...
}: let
  tv = pkgs.writeShellScriptBin "tv" ''
    exec ${pkgs.curl}/bin/curl -fsS -m 5 --retry 5 --retry-connrefused -X POST "http://${inputs.self.network.home.hosts.tv}:8060/$1"
  '';
  tile = name: exec:
    pkgs.makeDesktopItem {
      inherit name exec;
      desktopName = name;
      icon = "applications-multimedia";
    };
  webapp = name: url: tile name "plasma-bigscreen-webapp --name ${name} ${url}";
in {
  jovian.steam.desktopSession = "plasma-bigscreen-wayland";
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sessionPackages = [pkgs.kdePackages.plasma-bigscreen];

  systemd.user.services.tv-input = {
    description = "Wake the TV and switch it to catbox";
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ["-${tv}/bin/tv keypress/PowerOn" "${tv}/bin/tv launch/tvinput.hdmi1"];
    };
  };

  services.sunshine.settings.global_prep_cmd = builtins.toJSON [
    {
      do = "${pkgs.writeShellScript "tv-off" "${tv}/bin/tv keypress/PowerOff || true"}";
      undo = "";
    }
  ];

  environment.systemPackages = [
    tv
    pkgs.kdePackages.plasma-bigscreen
    pkgs.kdePackages.plasmatube
    pkgs.jellyfin-desktop
    (webapp "YouTube" "https://www.youtube.com/tv")
    (webapp "Navidrome" "https://navidrome.milberry.org")
    (webapp "Pinepods" "https://podcasts.milberry.org")
    (webapp "Seerr" "https://requests.lianas.org")
    (tile "Roku" "tv keypress/Home")
  ];
}
