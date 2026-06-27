# @desc: GnuPG agent (SSH support) + gnome-keyring via PAM
{...}: {
  flake.modules.nixos.keyring = {pkgs, ...}: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.gnome.gnome-keyring = {
      enable = true;
    };

    security.pam = {
      services = {
        swaylock.fprintAuth = false;
        swaylock.u2fAuth = false;
        sudo.fprintAuth = false;
        sudo.u2fAuth = false;
        greetd.fprintAuth = false;
        login.fprintAuth = false;
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
