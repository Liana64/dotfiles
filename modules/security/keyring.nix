# @desc: GnuPG agent (SSH support), ssh askpass + gnome-keyring via PAM
_: {
  flake.modules.nixos.keyring = {
    config,
    lib,
    pkgs,
    ...
  }: let
    pinentry = lib.getExe config.programs.gnupg.agent.pinentryPackage;
    askpass = pkgs.writeShellApplication {
      name = "ssh-askpass-pinentry";
      runtimeInputs = [pkgs.gnugrep pkgs.gnused];
      text = ''
        desc=''${1//%/%25}
        desc=''${desc//$'\n'/%0A}
        case "''${SSH_ASKPASS_PROMPT:-}" in
          none) exec ${pinentry} <<EOF
        SETDESC $desc
        MESSAGE
        EOF
          ;;
          confirm) cmd=CONFIRM ;;
          *) cmd=GETPIN ;;
        esac
        out=$(${pinentry} <<EOF
        SETDESC $desc
        SETPROMPT PIN:
        $cmd
        EOF
        )
        printf '%s\n' "$out" | grep -q '^ERR' && exit 1
        printf '%s\n' "$out" | sed -n 's/^D //p' | sed 's/%25/%/g'
      '';
    };
  in {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    programs.ssh = {
      enableAskPassword = true;
      askPassword = lib.getExe askpass;
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
