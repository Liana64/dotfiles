# @desc: auditd audit logging
{...}: let
  agentExe = "/var/lib/audit-exe/gpg-agent";
in {
  flake.modules.nixos.auditd = {
    pkgs,
    config,
    lib,
    hardening,
    ...
  }: let
    austatus = pkgs.writeShellScriptBin "austatus" (builtins.readFile ../bin/austatus);
    wallKeys = ["usbguard" "gnupg-secrets" "gnupg-tamper" "code-injection" "data-injection" "register-injection" "ptrace-attach" "32bit-abi" "exec-scratch" "memfd-exec"];
    spaceLeftMB = 2048;
    gnupgKeys = "${config.users.users.liana.home}/.gnupg/private-keys-v1.d";
    agentSrc = "${config.home-manager.users.liana.programs.gpg.package}/bin/gpg-agent";
    usbguard = config.services.usbguard;
    scratchDirs = ["/tmp" "/var/tmp"];
    usbguardIPC = "/var/lib/usbguard/IPCAccessControl.d";
    ptraceRequests = {
      ptrace-attach = ["0x10" "0x4206"];
      code-injection = ["0x4"];
      data-injection = ["0x5"];
      register-injection = ["0x6" "0xd" "0xf" "0x1e" "0x4205" "0x4210" "0x4212"];
    };
  in {
    security.auditd.enable = true;
    security.auditd.settings = {
      max_log_file = 16;
      max_log_file_action = "rotate";
      num_logs = 5;
      priority_boost = 0;
      space_left = spaceLeftMB;
      space_left_action = "syslog";
      admin_space_left_action = "syslog";
      disk_full_action = "syslog";
      disk_error_action = "syslog";
    };
    security.audit = {
      enable = "lock";
      backlogLimit = 8192;
      rules =
        [
          "-a never,exit -F gid=${toString config.ids.gids.nixbld}"
          "-a never,exclude -F msgtype=BPF -F pid=1"
          "-a never,exit -F arch=b64 -F dir=${gnupgKeys} -F perm=rwa -F exe=${agentExe}"
          "-a always,exit -F arch=b64 -F dir=${gnupgKeys} -F perm=r -k gnupg-secrets"
          "-a always,exit -F arch=b64 -F dir=${gnupgKeys} -F perm=wa -k gnupg-tamper"
        ]
        ++ map (f: "-w ${f} -p wa -k identity") ["/etc/passwd" "/etc/group" "/etc/shadow" "/etc/sudoers"]
        ++ lib.optionals usbguard.enable [
          "-w ${usbguard.ruleFile} -p wa -k usbguard"
          "-w ${usbguardIPC} -p wa -k usbguard"
        ]
        ++ [
          "-w /var/log/audit -p wa -k audit-tamper"

          "-a always,exit -F arch=b64 -S init_module,finit_module -k module-load"
          "-a always,exit -F arch=b64 -S delete_module -k module-unload"

          "-a never,exit -F arch=b64 -F dir=/nix/var/nix/db -F perm=wa -F exe=${config.nix.package.nix-cli or config.nix.package}/bin/nix"
          "-a always,exit -F arch=b64 -F dir=/nix/var/nix/db -F perm=wa -k nix-db"

          "-a always,exit -F arch=b64 -S process_vm_writev -k data-injection"
          "-a always,exit -F arch=b64 -S memfd_create -F a1&0x10 -F success=1 -k memfd-exec"
          "-a always,exit -F arch=b32 -S all -k 32bit-abi"
        ]
        ++ lib.concatLists (lib.mapAttrsToList (key: map (req: "-a always,exit -F arch=b64 -S ptrace -F a0=${req} -k ${key}")) ptraceRequests)
        # dir= matches every inode a syscall touches, and the ELF interpreter lives
        # in /nix/store, so writable-tree execs must precede the store exclusion
        ++ map (exec: "-a always,exit -F arch=b64 -S execve,execveat ${exec}") (
          ["-F dir=/dev/shm -k exec-scratch"]
          ++ map (d: "-F dir=${d} -F auid=unset -k exec-scratch") scratchDirs
          ++ map (d: "-F dir=${d} -k exec-scratch-user") (scratchDirs ++ ["/run/user"])
          ++ ["-F dir=/home -k exec-home"]
        )
        ++ [
          "-a never,exit -F arch=b64 -S execve,execveat -F dir=/nix/store"
          "-a never,exit -F arch=b64 -S execve,execveat -F dir=/run/wrappers"
          "-a never,exit -F arch=b64 -S execve,execveat -F dir=/var/lib/flatpak"
          "-a always,exit -F arch=b64 -S execve,execveat -F success=1 -k exec-nonstore"
          # euid is the init-namespace uid, so unprivileged userns mounts never match
          "-a always,exit -F arch=b64 -S mount,mount_setattr,move_mount,fsmount -F auid>=1000 -F auid!=unset -F euid=0 -k mount-tamper"
        ];
    };

    boot.kernel.sysctl."vm.memfd_noexec" = 1;

    system.activationScripts.audit-exe = ''
      install -d -m 0755 ${dirOf agentExe}
      if ! ${pkgs.diffutils}/bin/cmp -s ${agentSrc} ${agentExe}; then
        install -m 0555 ${agentSrc} ${agentExe}.tmp
        mv -f ${agentExe}.tmp ${agentExe}
      fi
    '';

    # Watch targets must exist when rules load at sysinit, or auditctl -R aborts
    # and drops every rule after the failing line, including the -e 2 lock
    systemd.tmpfiles.rules =
      [
        "d /var/log/audit 0700 root root -"
        "d /var/lib/audit-wall 0755 root root -"
        "d /var/lib/audit-wall/alerts 0755 root root -"
        "d /var/lib/audit-wall/latch 0755 root root -"
      ]
      ++ lib.optional usbguard.enable "d ${usbguardIPC} 0755 root root -";
    # no seccomp filter, a SIGSYS'd auditd at boot means no audit trail, and
    # RefuseManualStop blocks --live probes; PrivateNetwork would sever the
    # init-namespace audit netlink, CAP_CHOWN covers log_group rotation chowns
    systemd.services.auditd.serviceConfig =
      builtins.removeAttrs hardening.confined ["SystemCallFilter" "MemoryDenyWriteExecute" "ProcSubset" "UMask"]
      // {
        RestrictAddressFamilies = "AF_UNIX AF_NETLINK";
        CapabilityBoundingSet = "CAP_AUDIT_CONTROL CAP_AUDIT_READ CAP_AUDIT_WRITE CAP_CHOWN";
        Nice = -4;
      };

    systemd.services.audit-rules-nixos = {
      after = ["systemd-tmpfiles-setup.service"];
      restartIfChanged = false;
      serviceConfig.ExecCondition = pkgs.writeShellScript "audit-unlocked" ''
        ! ${config.security.audit.package}/bin/auditctl -s | ${pkgs.gnugrep}/bin/grep -qx 'enabled 2'
      '';
      serviceConfig.ExecStartPre = "-${config.systemd.package}/bin/systemd-tmpfiles --create ${pkgs.writeText "audit-gnupg.conf" ''
        d ${dirOf gnupgKeys} 0700 liana users -
        d ${gnupgKeys} 0700 liana users -
      ''}";
    };

    environment.systemPackages = [austatus];

    systemd.services.audit-wall = {
      path = [config.security.audit.package];
      environment.BOOT_ID = "%b";
      script = ''
        ack=/var/lib/audit-wall/ack
        banner=/run/audit-wall/banner
        [ -s "$ack" ] || date '+%m/%d/%Y %T' > "$ack"
        summary=""
        status=$(auditctl -s 2>/dev/null)
        # a rule that fails at boot drops the -e 2 lock silently
        echo "$status" | grep -qx 'enabled 2' || summary="$summary audit-unlocked"
        apid=$(echo "$status" | sed -n 's/^pid //p')
        if [ "''${apid:-0}" -eq 0 ]; then summary="$summary auditd-dead"; fi
        lost=$(echo "$status" | sed -n 's/^lost //p')
        lost=''${lost:-0}
        boot=$BOOT_ID
        base=/var/lib/audit-wall/lost
        read -r bboot blost 2>/dev/null < "$base" || true
        if ! [ "$base" -nt "$ack" ]; then
          bboot=$boot blost=$lost
        elif [ "$bboot" != "$boot" ]; then
          bboot=$boot blost=0
        fi
        echo "$bboot $blost" > "$base"
        if [ "$lost" -gt "$blost" ]; then summary="$summary audit-lost:$((lost - blost))"; fi
        # Rule (re)loads tag the key on a CONFIG_CHANGE bundled with an auditctl
        # SYSCALL keyed (null); match key on SYSCALL so reboots/switches don't trip.
        # $ack is "date time": -ts needs it as two args, so it must stay unquoted
        keys=$(ausearch -ts $(cat "$ack") 2>/dev/null | grep '^type=SYSCALL' | grep -oE 'key="[^"]*"' || true)
        for key in ${toString wallKeys}; do
          count=$(printf '%s\n' "$keys" | grep -cx "key=\"$key\"" || true)
          latch=/var/lib/audit-wall/latch/$key
          if [ "$latch" -nt "$ack" ] && [ "$(cat "$latch")" -gt "$count" ]; then count=$(cat "$latch"); fi
          if [ "$count" -gt 0 ]; then
            echo "$count" > "$latch"
            summary="$summary $key:$count"
          fi
        done
        for f in /var/lib/audit-wall/alerts/*; do
          if [ -s "$f" ]; then summary="$summary ''${f##*/}:$(wc -l <"$f")"; fi
        done
        failed=$(systemctl list-units --failed --no-legend --plain | wc -l)
        if [ "$failed" -gt 0 ]; then summary="$summary failed-units:$failed"; fi
        # stateless df poll instead of auditd exec actions, banner self-clears
        free=$(df --output=avail -m /var/log | tail -n1 | tr -d ' ')
        if [ "$free" -lt ${toString spaceLeftMB} ]; then summary="$summary audit-disk:''${free}MB-free"; fi
        new=""
        if [ -n "$summary" ]; then
          new="audit wall: $summary (austatus for details, 'austatus ack' clears)"
        fi
        # unchanged rewrites would retrigger the notify path unit below
        if [ "$new" != "$(cat "$banner" 2>/dev/null)" ]; then
          if [ -n "$new" ]; then echo "$new" > "$banner"; else : > "$banner"; fi
        fi
      '';
      serviceConfig =
        hardening.confined
        // {
          Type = "oneshot";
          CapabilityBoundingSet = "CAP_AUDIT_CONTROL";
          RestrictAddressFamilies = ["AF_UNIX" "AF_NETLINK"];
          ReadWritePaths = ["/var/lib/audit-wall"];
          RuntimeDirectory = "audit-wall";
          RuntimeDirectoryMode = "0755";
          RuntimeDirectoryPreserve = true;
          ProtectProc = "default";
          UMask = "0022";
        };
    };
    systemd.timers.audit-wall = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "10min";
      };
    };
  };

  flake.modules.homeManager.auditd = {
    config,
    lib,
    pkgs,
    hardening,
    ...
  }: {
    systemd.user.services.gpg-agent = lib.mkIf config.services.gpg-agent.enable {
      Unit.X-Restart-Triggers = ["${config.programs.gpg.package}"];
      Service.ExecStart = lib.mkForce "${agentExe} --supervised";
    };

    systemd.user.paths.audit-wall-notify = {
      Unit.Description = "Watch the audit wall banner";
      Path.PathChanged = "/run/audit-wall/banner";
      Install.WantedBy = ["graphical-session.target"];
    };
    systemd.user.services.audit-wall-notify = {
      Unit.Description = "Audit wall desktop notification";
      Unit.After = ["graphical-session.target"];
      Install.WantedBy = ["graphical-session.target"];
      Service =
        hardening.base
        // {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "audit-wall-notify" ''
            banner=/run/audit-wall/banner
            idf=$XDG_RUNTIME_DIR/audit-wall-notify.id
            if [ -s "$banner" ]; then
              id=$(cat "$idf" 2>/dev/null || echo 0)
              ${pkgs.libnotify}/bin/notify-send -p -r "$id" -u critical -a audit-wall -t 0 \
                "Audit wall" "$(cat "$banner")" > "$idf"
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
