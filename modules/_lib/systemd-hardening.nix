# @desc: Staged systemd unit hardening (not imported)
rec {
  # one "Key=Value" per property; list attrs get an entry per element
  lines = preset:
    builtins.concatMap (
      k: let
        v = preset.${k};
      in
        if builtins.isList v
        then map (x: "${k}=${builtins.toString x}") v
        else [
          "${k}=${
            if builtins.isBool v
            then
              (
                if v
                then "true"
                else "false"
              )
            else builtins.toString v
          }"
        ]
    ) (builtins.attrNames preset);

  args = preset: builtins.concatStringsSep " " (map (l: "-p ${l}") (lines preset));

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

  # these three overmount /proc paths in the mount namespace, and the kernel
  # then refuses bwrap's fresh procfs mount — flatpak dies; hostname's bind
  # activates only alongside mount-ns properties. The additions hold for GUI
  # apps: 32-bit ABI unused (wine would SIGSYS) and a child userns resets its
  # own bounding set, so bwrap and browser sandboxes keep their caps
  launch =
    builtins.removeAttrs base ["ProtectKernelTunables" "ProtectKernelLogs" "ProtectHostname"]
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
      # true also masks /run/user (wayland/dbus sockets) — graphical consumers
      # override to read-only + ReadWritePaths=%t
      ProtectHome = true;
      PrivateDevices = true;
      ProtectControlGroups = true;
      ProcSubset = "pid";
      RestrictNamespaces = true;
      MemoryDenyWriteExecute = true;
      SystemCallArchitectures = "native";
      # Qt/GTK apps SIGSYS under ~@resources (affinity/priority/scheduler) —
      # those consumers drop the third element
      SystemCallFilter = ["@system-service" "~@privileged" "~@resources"];
      UMask = "0077";
    };

  airgapped =
    confined
    // {
      RestrictAddressFamilies = ["AF_UNIX"];
      IPAddressDeny = "any";
    };
}
