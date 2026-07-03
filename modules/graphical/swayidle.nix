# @desc: swayidle idle/lock daemon as a restarting user service
{...}: {
  flake.modules.homeManager.swayidle = {pkgs, ...}: let
    # after-resume works around waybar duplicating bars on resume
    # (Alexays/Waybar#3344, #3964; fix in draft PR #3669)
    idleScript = pkgs.writeShellScript "swayidle-session" ''
      exec ${pkgs.swayidle}/bin/swayidle -w \
        timeout 300 '[ -e "$XDG_RUNTIME_DIR/caffeinate" ] || swaylock -f' \
        timeout 600 '[ -e "$XDG_RUNTIME_DIR/caffeinate" ] || swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
        lock 'swaylock -f' \
        before-sleep 'swaylock -f' \
        after-resume 'systemctl --user try-restart waybar.service'
    '';
  in {
    systemd.user.services.swayidle = {
      Unit = {
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      # No hardening preset: children include swaylock, whose PAM unlock
      # needs the setuid unix_chkpwd helper — NoNewPrivileges would deny
      # every correct password
      Service = {
        ExecStart = "${idleScript}";
        Restart = "on-failure";
      };
    };
  };
}
