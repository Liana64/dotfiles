{
  config,
  pkgs,
  colors,
  ...
}: {
  systemd.user.services.swaybg = with colors; {
    Unit = {
      After = ["sway-session.target"];
      Requisite = ["sway-session.target"];
      PartOf = ["sway-session.target"];
    };
    Install = {
      WantedBy = ["sway-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
      Restart = "on-failure";
    };
  };
}
