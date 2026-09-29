# @desc: GnuPG agent (SSH support) + gnome-keyring via PAM
{...}: {
  flake.modules.nixos.keyring = {...}: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.gnome.gnome-keyring = {
      enable = true;
    };

    security.pam = {
      services = {
        swaylock.u2fAuth = false;
        sudo.u2fAuth = false;
        login.u2fAuth = false;
        greetd.enableGnomeKeyring = true;
        sway.enableGnomeKeyring = true;
      };

      u2f = {
        enable = true;
        settings = {
          cue = true; # Prompt when waiting for touch
        };
      };
    };
  };
}
