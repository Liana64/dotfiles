# @desc: GnuPG agent (SSH support), ssh askpass + gnome-keyring via PAM
{...}: {
  flake.modules.nixos.keyring = {pkgs, ...}: {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.ssh = {
      enableAskPassword = true;
      askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
    };

    environment.variables.SSH_ASKPASS_REQUIRE = "prefer";

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
