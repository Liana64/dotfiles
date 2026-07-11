# @desc: swayidle idle/lock daemon as a restarting user service
{...}: {
  flake.modules.homeManager.swayidle = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
    # swaylock lives in its own unit so it escapes swayidle's sandbox; the
    # start job blocks until the lock is up, preserving -w before-sleep semantics
    lock = "systemctl --user start swaylock.service";
    # after-resume works around waybar duplicating bars on resume
    # (Alexays/Waybar#3344, #3964; fix in draft PR #3669)
    idleScript = pkgs.writeShellScript "swayidle-session" ''
      exec ${pkgs.swayidle}/bin/swayidle -w \
        timeout 300 '[ -e "$XDG_RUNTIME_DIR/caffeinate" ] || ${lock}' \
        timeout 600 '[ -e "$XDG_RUNTIME_DIR/caffeinate" ] || swaymsg "output * power off"' \
        resume 'swaymsg "output * power on"' \
        lock '${lock}' \
        before-sleep '${lock}' \
        after-resume 'systemctl --user try-restart waybar.service'
    '';
  in {
    # No hardening: PAM unlock needs the setuid unix_chkpwd helper, which any
    # seccomp or mount sandbox on a user unit would break (implied NoNewPrivileges
    # / unmapped userns) — a lockout, not a degradation
    systemd.user.services.swaylock = {
      Unit.Description = "Screen locker";
      Service = {
        # forking: swaylock -f daemonizes only once the screen is locked
        Type = "forking";
        ExecStart = "${pkgs.swaylock}/bin/swaylock -f";
      };
    };

    systemd.user.services.swayidle = {
      Unit = {
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      Service =
        hardening.confined
        // {
          ExecStart = "${idleScript}";
          Restart = "on-failure";
          # /run/user carries the wayland/sway sockets and the caffeinate flag
          ProtectHome = "read-only";
        };
    };
  };
}
