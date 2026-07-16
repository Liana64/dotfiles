# @desc: Log flood tripwire: journal/audit event-rate + journal near-cap alert into audit-wall
{...}: {
  flake.modules.nixos.logFlood = {...}: let
    hardening = import ../_lib/systemd-hardening.nix;
    journalBurst = 20000; # msgs per timer interval
    auditBurst = 10000; # events per timer interval
    journalNearCapMB = 900; # eviction pressure, SystemMaxUse=1G in journald.nix
  in {
    systemd.services.log-flood = {
      script = ''
        state=/var/lib/audit-wall/log-flood.state
        alert=/var/lib/audit-wall/alerts/log-flood
        jseq=$(journalctl -q -n1 -o export | sed -n 's/^__SEQNUM=//p')
        aser=$(tail -n1 /var/log/audit/audit.log 2>/dev/null | sed -n 's/.*audit([0-9]*\.[0-9]*:\([0-9]*\)).*/\1/p')
        jmb=$(du -sm /var/log/journal | cut -f1)
        read -r pjseq paser < "$state" || { pjseq=''${jseq:-0}; paser=''${aser:-0}; }
        printf '%s %s\n' "''${jseq:-0}" "''${aser:-0}" > "$state"
        jd=$((''${jseq:-0} - pjseq))
        ad=$((''${aser:-0} - paser))
        : > "$alert.new"
        [ "$jd" -gt ${toString journalBurst} ] && echo "journal +$jd msgs last interval" >> "$alert.new"

        # audit serials reset at boot
        [ "$ad" -gt ${toString auditBurst} ] && echo "audit +$ad events last interval" >> "$alert.new"
        [ "$jmb" -gt ${toString journalNearCapMB} ] && echo "journal ''${jmb}MB nearing cap" >> "$alert.new"
        # a burst can end before audit-wall samples it, alert stays until austatus ack
        if [ -s "$alert.new" ]; then
          mv "$alert.new" "$alert"
        else
          rm -f "$alert.new"
          if [ /var/lib/audit-wall/ack -nt "$alert" ]; then rm -f "$alert"; fi
        fi
      '';
      serviceConfig =
        hardening.base
        // {
          Type = "oneshot";
          ProtectHome = true;
          PrivateNetwork = true;
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_UNIX";
          SystemCallArchitectures = "native";
        };
    };
    systemd.timers.log-flood = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "5min";
        OnUnitActiveSec = "10min";
      };
    };
  };
}
