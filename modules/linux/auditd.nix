{pkgs, ...}: let
  austatus = pkgs.writeShellScriptBin "austatus" (builtins.readFile ./bin/austatus);
  # Keys that are silent in normal operation; excludes boot/rebuild noise
  # (module-load, identity, audit-tamper)
  tripwireKeys = ["usbguard" "code-injection" "data-injection" "register-injection" "32bit-abi"];
in {
  # DISA RHEL STIG subset: tamper signals only, not full coverage
  security.auditd.enable = true;
  # NixOS conf omits rotation; daemon default is ignore (unbounded growth)
  security.auditd.settings = {
    max_log_file = 8;
    max_log_file_action = "rotate";
    num_logs = 5;
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
      # Unfiltered: catches module loads by compromised daemons, not just users
      "-a always,exit -F arch=b64 -S init_module,finit_module -k module-load"
      "-a always,exit -F arch=b64 -S delete_module -k module-unload"
      # ptrace_scope=2 makes any successful injection root-level; should never fire
      "-a always,exit -F arch=b64 -S ptrace -F a0=0x4 -k code-injection"
      "-a always,exit -F arch=b64 -S ptrace -F a0=0x5 -k data-injection"
      "-a always,exit -F arch=b64 -S ptrace -F a0=0x6 -k register-injection"
      # No 32-bit software installed; any compat syscall is an exploit signal
      "-a always,exit -F arch=b32 -S all -k 32bit-abi"
    ];
  };

  # Watch targets must exist when rules load at sysinit, or auditctl -R aborts
  # and drops every rule after the failing line, including the -e 2 lock
  systemd.tmpfiles.rules = [
    "d /var/log/audit 0700 root root -"
    "d /etc/usbguard 0700 root root -"
    "d /var/lib/audit-tripwires 0755 root root -"
  ];
  systemd.services.audit-rules-nixos.after = ["systemd-tmpfiles-setup.service"];

  environment.systemPackages = [austatus];

  # Audit log is 0700 root; a root timer writes a world-readable tripwire
  # summary that interactive shells display
  systemd.services.audit-tripwires = {
    script = ''
      ack=/var/lib/audit-tripwires/ack
      [ -s "$ack" ] || date '+%m/%d/%Y %T' > "$ack"
      summary=""
      for key in ${toString tripwireKeys}; do
        # Rule (re)loads tag the key on a CONFIG_CHANGE bundled with an auditctl
        # SYSCALL keyed (null); match key on SYSCALL so reboots/switches don't trip.
        count=$(${pkgs.audit}/bin/ausearch -k "$key" -ts $(cat "$ack") 2>/dev/null | grep 'type=SYSCALL' | grep -Ec 'key="?'"$key" || true)
        if [ "$count" -gt 0 ]; then summary="$summary $key:$count"; fi
      done
      if [ -n "$summary" ]; then
        echo "audit tripwires: $summary (austatus for details, 'austatus ack' clears)" > /run/audit-tripwires
        echo ""
      else
        : > /run/audit-tripwires
      fi
      chmod 0644 /run/audit-tripwires
    '';
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.audit-tripwires = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "10min";
    };
  };
}
