{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.usbguard;
  ruleFile =
    if cfg.rules != null
    then pkgs.writeText "usbguard-rules" cfg.rules
    else cfg.ruleFile;
  # Fork of the nixpkgs daemon conf: AuditBackend=LinuxAudit routes device
  # events into auditd instead of the AuditFilePath=/dev/null journal hack.
  # Values come from cfg so option changes stay in sync.
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
  # Prevent unauthorized USBs from mounting
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

  # Configure the automatic mounting of external
  # USB drives; note that they are mounted according
  # to the user that is active, meaning that it can
  # be the lightdm user when the system is booting
  # or, otherwise, the user that is logged in
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  environment.systemPackages = with pkgs; [
    usbguard
  ];

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
}
