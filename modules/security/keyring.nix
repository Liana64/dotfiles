# @desc: GnuPG agent (SSH support) + gnome-keyring via PAM
{...}: {
  flake.modules.nixos.keyring = {...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # pinentry children are Qt/GTK (@resources SIGSYS otherwise) and scdaemon
    # may drive the YubiKey over raw USB; keys need ~/.gnupg writable
    systemd.user.services.gpg-agent.serviceConfig =
      hardening.confined
      // {
        SystemCallFilter = ["@system-service" "~@privileged"];
        PrivateDevices = false;
        ProtectHome = "read-only";
        ReadWritePaths = "%t %h/.gnupg";
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
