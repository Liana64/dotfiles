{ pkgs, ... }: { 
  # Prevent unauthorized USBs from mounting
  # Use `usbguard generate-policy > /etc/usbguard/rules.conf && chmod 600 /etc/usbguard/rules.conf`
  # to write authorized defaults
  services.usbguard = {
    enable = true;
    presentControllerPolicy = "apply-policy";
    IPCAllowedGroups = [ "wheel" ];
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
}
