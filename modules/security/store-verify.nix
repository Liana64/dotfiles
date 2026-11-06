# @desc: Weekly nix store verify with tamper alert
{...}: {
  flake.modules.nixos.storeVerify = {
    config,
    pkgs,
    hardening,
    ...
  }: {
    systemd.services.store-ro = {
      path = [pkgs.util-linux];
      script = ''
        alert=$STATE_DIRECTORY/store-rw
        opts=$(findmnt --task 1 -no OPTIONS --mountpoint /nix/store)
        if [[ ,$opts, == *,ro,* ]]; then
          rm -f "$alert"
        else
          printf '/nix/store mounted %s in the host namespace\n' "$opts" >"$alert"
        fi
      '';
      serviceConfig =
        hardening.airgapped
        // {
          Type = "oneshot";
          StateDirectory = "audit-wall/alerts";
          UMask = "0022";
        };
    };
    systemd.timers.store-ro = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "10min";
      };
    };

    systemd.services.nix-store-verify = {
      script = ''
        alert=/var/lib/audit-wall/alerts/store-verify
        mkdir -p "''${alert%/*}"
        if out=$(${config.nix.package}/bin/nix store verify --all --no-trust --quiet 2>&1); then
          rm -f "$alert"
        else
          printf '%s\n' "$out" >"$alert"
          exit 1
        fi
      '';
      # nix client as root remounts /nix/store rw in a private mount ns
      # (SYS_ADMIN + mnt), verify reads only local db + sigs, no homes, no net
      serviceConfig =
        hardening.base
        // {
          Type = "oneshot";
          CPUSchedulingPolicy = "idle";
          IOSchedulingClass = "idle";
          CapabilityBoundingSet = "CAP_SYS_ADMIN";
          RestrictNamespaces = "mnt";
          ProtectHome = true;
          PrivateNetwork = true;
          PrivateDevices = true;
          RestrictAddressFamilies = "AF_UNIX";
          SystemCallArchitectures = "native";
        };
    };
    systemd.timers.nix-store-verify = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
    };
  };
}
