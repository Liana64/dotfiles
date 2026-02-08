{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.swaybg = {
    Unit = {
      After = ["sway-session.target"];
      Requisite = ["sway-session.target"];
      PartOf = ["sway-session.target"];
    };
    Install = {
      WantedBy = ["sway-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i /home/liana/.dotfiles/wallpapers/space.png -m fill";
      Restart = "on-failure";
    };
  };
}
