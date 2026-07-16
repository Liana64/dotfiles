# @desc: auditd audit logging
{...}: {
  flake.modules.nixos.auditd = {
    pkgs,
    config,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
    austatus = pkgs.writeShellScriptBin "austatus" (builtins.readFile ../bin/austatus);
    wallKeys = ["usbguard" "code-injection" "data-injection" "register-injection" "32bit-abi" "exec-scratch"];
    spaceLeftMB = 2048;
  in {
    # DISA RHEL STIG subset: tamper signals only, not full coverage
    security.auditd.enable = true;
    # NixOS conf omits rotation; daemon default is ignore (unbounded growth)
    security.auditd.settings = {
      max_log_file = 16;
      max_log_file_action = "rotate";
      num_logs = 5;
      # daemon default suspends logging under disk pressure
      space_left = spaceLeftMB;
      space_left_action = "syslog";
      admin_space_left_action = "syslog";
      disk_full_action = "syslog";
      disk_error_action = "syslog";
    };
    security.audit = {
      # "lock" appends -e 2: rules immutable until reboot, so root can't silently remove them
      enable = "lock";
      backlogLimit = 8192;
      rules = [
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/sudoers -p wa -k identity"

        "-w /etc/usbguard -p wa -k usbguard"

        "-w /var/log/audit -p wa -k audit-tamper"

        "-a always,exit -F arch=b64 -S init_module,finit_module -k module-load"
        "-a always,exit -F arch=b64 -S delete_module -k module-unload"

        "-a never,exit -F arch=b64 -F dir=/nix/var/nix/db -F perm=wa -F exe=${config.nix.package.nix-cli or config.nix.package}/bin/nix"
        "-a always,exit -F arch=b64 -F dir=/nix/var/nix/db -F perm=wa -k nix-db"

        "-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code-injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data-injection"
        "-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register-injection"

        "-a always,exit -F arch=b32 -S all -k 32bit-abi"

        "-a never,exit -F arch=b64 -S execve,execveat -F dir=/nix/store"
        "-a never,exit -F arch=b64 -S execve,execveat -F dir=/run/wrappers"
        "-a never,exit -F arch=b64 -S execve,execveat -F uid>=30001 -F uid<=30999"
        "-a always,exit -F arch=b64 -S execve,execveat -F dir=/tmp -k exec-scratch"
        "-a always,exit -F arch=b64 -S execve,execveat -F dir=/var/tmp -k exec-scratch"
        "-a always,exit -F arch=b64 -S execve,execveat -F dir=/dev/shm -k exec-scratch"
        "-a always,exit -F arch=b64 -S execve,execveat -F success=1 -k exec-nonstore"

        "-a never,exit -F arch=b64 -S mount,mount_setattr,move_mount,fsmount -F exe=${config.systemd.package}/lib/systemd/systemd-executor"
        "-a never,exit -F arch=b64 -S mount,mount_setattr,move_mount,fsmount -F exe=${pkgs.bubblewrap}/bin/bwrap"
        "-a always,exit -F arch=b64 -S mount,mount_setattr,move_mount,fsmount -F auid>=1000 -F auid!=unset -k mount-tamper"
      ];
    };

    # Watch targets must exist when rules load at sysinit, or auditctl -R aborts
    # and drops every rule after the failing line, including the -e 2 lock
    systemd.tmpfiles.rules = [
      "d /var/log/audit 0700 root root -"
      "d /etc/usbguard 0700 root root -"
      "d /var/lib/audit-wall 0755 root root -"
      "d /var/lib/audit-wall/alerts 0755 root root -"
    ];
    # no seccomp filter, a SIGSYS'd auditd at boot means no audit trail, and
    # RefuseManualStop blocks --live probes; PrivateNetwork would sever the
    # init-namespace audit netlink, CAP_CHOWN covers log_group rotation chowns
    systemd.services.auditd.serviceConfig =
      hardening.base
      // {
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateDevices = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
        RestrictAddressFamilies = "AF_UNIX AF_NETLINK";
        CapabilityBoundingSet = "CAP_AUDIT_CONTROL CAP_AUDIT_READ CAP_AUDIT_WRITE CAP_CHOWN";
      };

    systemd.services.audit-rules-nixos = {
      after = ["systemd-tmpfiles-setup.service"];
      restartIfChanged = false;
      serviceConfig.ExecCondition = pkgs.writeShellScript "audit-unlocked" ''
        ! ${pkgs.audit}/bin/auditctl -s | ${pkgs.gnugrep}/bin/grep -qx 'enabled 2'
      '';
    };

    environment.systemPackages = [austatus];

    # a rule that fails at boot drops the -e 2 lock silently
    systemd.services.audit-lock-check = {
      wantedBy = ["multi-user.target"];
      after = ["audit-rules-nixos.service"];
      script = ''
        alert=/var/lib/audit-wall/alerts/audit-lock
        if ${pkgs.audit}/bin/auditctl -s | grep -qx 'enabled 2'; then
          rm -f "$alert"
        else
          ${pkgs.audit}/bin/auditctl -s > "$alert"
        fi
      '';
      serviceConfig.Type = "oneshot";
    };

    # Audit log is 0700 root; a root timer writes a world-readable wall
    # summary that interactive shells display
    systemd.services.audit-wall = {
      script = ''
        ack=/var/lib/audit-wall/ack
        [ -s "$ack" ] || date '+%m/%d/%Y %T' > "$ack"
        summary=""
        for key in ${toString wallKeys}; do
          # Rule (re)loads tag the key on a CONFIG_CHANGE bundled with an auditctl
          # SYSCALL keyed (null); match key on SYSCALL so reboots/switches don't trip.
          # $ack is "date time": -ts needs it as two args, so it must stay unquoted
          count=$(${pkgs.audit}/bin/ausearch -k "$key" -ts $(cat "$ack") 2>/dev/null | grep 'type=SYSCALL' | grep -Ec 'key="?'"$key" || true)
          if [ "$count" -gt 0 ]; then summary="$summary $key:$count"; fi
        done
        for f in /var/lib/audit-wall/alerts/*; do
          if [ -s "$f" ]; then summary="$summary ''${f##*/}:$(wc -l <"$f")"; fi
        done
        # stateless df poll instead of auditd exec actions, banner self-clears
        free=$(df --output=avail -m /var/log | tail -n1 | tr -d ' ')
        if [ "$free" -lt ${toString spaceLeftMB} ]; then summary="$summary audit-disk:''${free}MB-free"; fi
        new=""
        if [ -n "$summary" ]; then
          new="audit wall: $summary (austatus for details, 'austatus ack' clears)"
        fi
        # unchanged rewrites would retrigger the notify path unit below
        if [ "$new" != "$(cat /run/audit-wall 2>/dev/null)" ]; then
          if [ -n "$new" ]; then echo "$new" > /run/audit-wall; else : > /run/audit-wall; fi
          chmod 0644 /run/audit-wall
        fi
      '';
      serviceConfig.Type = "oneshot";
    };
    systemd.timers.audit-wall = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "10min";
      };
    };
  };

  flake.modules.homeManager.auditd = {pkgs, ...}: {
    systemd.user.paths.audit-wall-notify = {
      Unit.Description = "Watch the audit wall banner";
      Path.PathChanged = "/run/audit-wall";
      Install.WantedBy = ["graphical-session.target"];
    };
    systemd.user.services.audit-wall-notify = {
      Unit.Description = "Audit wall desktop notification";
      Service = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "audit-wall-notify" ''
          idf=$XDG_RUNTIME_DIR/audit-wall-notify.id
          if [ -s /run/audit-wall ]; then
            id=$(cat "$idf" 2>/dev/null || echo 0)
            ${pkgs.libnotify}/bin/notify-send -p -r "$id" -u critical -a audit-wall -t 0 \
              "Audit wall" "$(cat /run/audit-wall)" > "$idf"
          elif [ -s "$idf" ]; then
            ${pkgs.glib}/bin/gdbus call --session --dest org.freedesktop.Notifications \
              --object-path /org/freedesktop/Notifications \
              --method org.freedesktop.Notifications.CloseNotification \
              "$(cat "$idf")" > /dev/null || true
            rm -f "$idf"
          fi
        '';
      };
    };
  };
}
