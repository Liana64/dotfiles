{
  pkgs,
  ...
}: {
  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  #services.openssh = {
  #  enable = true;
  #  settings = {
  #    # Opinionated: forbid root login through SSH.
  #    PermitRootLogin = "no";
  #    # Opinionated: use keys only.
  #    # Remove if you want to SSH using passwords
  #    PasswordAuthentication = false;
  #  };
  #};

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    #forcePageTableIsolation = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [pkgs.apparmor-profiles];
    };
  };

  # Configure the automatic mounting of external
  # USB drives; note that they are mounted according
  # to the user that is active, meaning that it can
  # be the lightdm user when the system is booting
  # or, otherwise, the user that is logged in
  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Smart card daemon for YubiKey
  services.pcscd.enable = true;

  services.udev.packages = [ pkgs.yubikey-personalization ];

  # TODO: Enable or remove
  #programs.yubikey-touch-detector.enable = true;
  
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubikey-personalization
  ];
  
  #programs.ssh.startAgent = false;

  # TODO: Test this
  security.pam.u2f = {
    enable = true;
    settings = {
      cue = true;  # Prompt when waiting for touch
      # authfile = "/etc/u2f_mappings";  # Or use per-user ~/.config/Yubico/u2f_keys
    };
  };

  security.pam.services.sudo.u2fAuth = true;
  security.pam.services.login.u2fAuth = false;
  security.pam.services.swaylock.u2fAuth = true;
}
