# @desc: systemd unit hardening
lib: rec {
  lines = preset:
    lib.concatLists (lib.mapAttrsToList (k: v:
      map (x: "${k}=${
        if builtins.isBool x
        then lib.boolToString x
        else toString x
      }") (lib.toList v))
    preset);

  args = preset: lib.concatMapStringsSep " " (l: "-p ${lib.escapeShellArg l}") (lines preset);

  base = {
    NoNewPrivileges = true;
    ProtectSystem = "full";
    PrivateTmp = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectKernelLogs = true;
    ProtectClock = true;
    ProtectHostname = true;
    ProtectProc = "invisible";
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
  };

  launch =
    removeAttrs base ["ProtectKernelTunables" "ProtectKernelLogs" "ProtectHostname"]
    // {
      ProtectControlGroups = true;
      SystemCallArchitectures = "native";
      CapabilityBoundingSet = "";
      UMask = "0077";
    };

  # This breaks a lot
  confined =
    base
    // {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateDevices = true;
      ProtectControlGroups = true;
      ProcSubset = "pid";
      RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];
      CapabilityBoundingSet = "";
      RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK"];
      UMask = "0077";
    };

  airgapped =
    confined
    // {
      RestrictAddressFamilies = ["AF_UNIX"];
      PrivateNetwork = true;
    };
}
