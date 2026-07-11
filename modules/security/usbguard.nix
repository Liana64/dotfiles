# @desc: USBGuard device authorization
{...}: {
  flake.modules.nixos.usbguard = {
    pkgs,
    lib,
    config,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
    cfg = config.services.usbguard;
    ruleFile =
      if cfg.rules != null
      then pkgs.writeText "usbguard-rules" cfg.rules
      else cfg.ruleFile;
    # Forked daemon conf for AuditBackend=LinuxAudit (events → auditd)
    daemonConf = pkgs.writeText "usbguard-daemon-conf" ''
      RuleFile=${ruleFile}
      ImplicitPolicyTarget=${cfg.implicitPolicyTarget}
      PresentDevicePolicy=${cfg.presentDevicePolicy}
      PresentControllerPolicy=${cfg.presentControllerPolicy}
      InsertedDevicePolicy=${cfg.insertedDevicePolicy}
      RestoreControllerDeviceState=${lib.boolToString cfg.restoreControllerDeviceState}
      DeviceManagerBackend=uevent
      IPCAllowedUsers=${lib.concatStringsSep " " cfg.IPCAllowedUsers}
      IPCAllowedGroups=${lib.concatStringsSep " " cfg.IPCAllowedGroups}
      IPCAccessControlFiles=/var/lib/usbguard/IPCAccessControl.d/
      DeviceRulesWithPort=${lib.boolToString cfg.deviceRulesWithPort}
      AuditBackend=LinuxAudit
    '';
  in {
    services.usbguard = {
      enable = true;
      presentControllerPolicy = "apply-policy";
      presentDevicePolicy = "keep";
      IPCAllowedGroups = ["wheel"];
      dbus.enable = true;

      # This is insecure since USB information can be dumped, but we'll do it anyway
      # TODO: Add a variable to disable this
      #ruleFile = "/var/secrets/usbguard/rules.conf";
      ruleFile = "/etc/usbguard/rules.conf";
    };

    services.devmon.enable = true;
    services.gvfs = {
      enable = true;
      package = (pkgs.gvfs.override {gnomeSupport = false;}).overrideAttrs (o: {
        mesonFlags = o.mesonFlags ++ ["-Dmtp=false" "-Dgphoto2=false" "-Dafc=false"];
      });
    };
    services.udisks2.enable = true;

    environment.systemPackages = with pkgs; [
      usbguard
    ];

    # dbus bridge: pure IPC client (system bus + usbguard socket as root),
    # no caps, no network, no devices; failure only degrades the waybar
    # indicator/GUI — policy enforcement lives in usbguard-daemon
    systemd.services.usbguard-dbus.serviceConfig =
      hardening.base
      // {
        ProtectHome = true;
        PrivateNetwork = true;
        PrivateDevices = true;
        CapabilityBoundingSet = "";
        RestrictAddressFamilies = "AF_UNIX";
        RestrictNamespaces = true;
        SystemCallArchitectures = "native";
      };

    systemd.services.usbguard = {
      preStart = ''
        if [ ! -s /etc/usbguard/rules.conf ]; then
          ${cfg.package}/bin/usbguard generate-policy > /etc/usbguard/rules.conf
          chmod 0600 /etc/usbguard/rules.conf
        fi
      '';
      serviceConfig = {
        ExecStart = lib.mkForce "${cfg.package}/bin/usbguard-daemon -P -k -c ${daemonConf}";
        # Audit netlink writes need CAP_AUDIT_WRITE
        CapabilityBoundingSet = lib.mkForce "CAP_CHOWN CAP_FOWNER CAP_AUDIT_WRITE";
        # Unit sandbox is ReadOnlyPaths=-/; preStart writes the policy here
        ReadWritePaths = lib.mkForce "-/dev/shm -/tmp -/etc/usbguard";
      };
    };
  };
}
