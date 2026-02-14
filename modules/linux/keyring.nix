{ pkgs, ... }: {
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

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.gnome.gnome-keyring = {
    enable = true;
  };

  security.pam = {
    services = {
      swaylock = {};
      swaylock.fprintAuth = true;
      swaylock.u2fAuth = false;
      sudo.fprintAuth = true;
      sudo.u2fAuth = true;
      #login.fprintAuth = true;
      login.u2fAuth = false;
      gdm.enableGnomeKeyring = true;
      sway.enableGnomeKeyring = true;
    };

    u2f = {
      enable = true;
      settings = {
        cue = true;  # Prompt when waiting for touch
      };
    };
  };
}
