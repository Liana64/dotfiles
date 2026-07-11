# @desc: swaybg wallpaper
{...}: {
  flake.modules.homeManager.swaybg = {
    pkgs,
    colors,
    ...
  }: let
    hardening = import ../../modules/_lib/systemd-hardening.nix;
  in {
    systemd.user.services.swaybg = with colors; {
      Unit = {
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
      Service =
        hardening.confined
        // {
          ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${wallpaper} -m fill";
          Restart = "on-failure";
          # ProtectHome=true would mask the wayland socket under /run/user
          ProtectHome = "read-only";
        };
    };
  };
}
