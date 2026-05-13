rec {
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
    RemoveIPC = true;
  };

  # This breaks a lot
  confined = base // {
    ProtectSystem = "strict";
    ProtectHome = true;
    PrivateDevices = true;
    ProtectControlGroups = true;
    ProcSubset = "pid";
    RestrictNamespaces = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    UMask = "0077";
  };

  airgapped = confined // {
    RestrictAddressFamilies = [ "AF_UNIX" ];
    IPAddressDeny = "any";
  };
}
