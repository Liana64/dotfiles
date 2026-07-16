# @desc: Weekly nix store verify with tamper alert
{...}: {
  flake.modules.nixos.storeVerify = {config, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    systemd.services.nix-store-verify = {
      script = ''
        alert=/var/lib/audit-wall/alerts/store-verify
        if out=$(${config.nix.package}/bin/nix store verify --all --no-trust 2>&1); then
          rm -f "$alert"
        else
          printf '%s\n' "$out" | grep '^error' >"$alert" || printf '%s\n' "$out" | tail -n 20 >"$alert"
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
