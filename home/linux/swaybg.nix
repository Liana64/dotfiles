{
  config,
  pkgs,
  colors,
  ...
}:
let
  hardening = import ../../modules/common/systemd-hardening.nix;
in
{
  systemd.user.services.swaybg = with colors; {
    Unit = {
      After = ["graphical-session.target"];
      Requisite = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = hardening.base // {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
      Restart = "on-failure";
    };
  };
}
