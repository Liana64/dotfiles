# Reusable systemd unit hardening profiles. Each tier extends the previous.
rec {
  # Kernel surface, suid, personality. /var stays writable.
  base = {
    NoNewPrivileges = true;
    ProtectSystem = "full";
    ProtectHome = true;
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

  # + FS read-only outside /var, /run, /tmp; namespace, device, and syscall locks.
  # Breaks bwrap, podman, suid helpers, and syscalls outside @system-service.
  confined = base // {
    ProtectSystem = "strict";
    PrivateDevices = true;
    ProtectControlGroups = true;
    ProcSubset = "pid";
    RestrictNamespaces = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = [ "@system-service" "~@privileged" "~@resources" ];
    UMask = "0077";
  };

  # + IP denial. Local IPC (AF_UNIX) only.
  airgapped = confined // {
    RestrictAddressFamilies = [ "AF_UNIX" ];
    IPAddressDeny = "any";
  };
}
