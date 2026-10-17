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
      text = ''
        desc=''${1//%/%25}
        desc=''${desc//$'\n'/%0A}
        case "''${SSH_ASKPASS_PROMPT:-}" in
          none) exit 0 ;;
          confirm) cmd=CONFIRM re=$'^OK[^\n]*\nOK\nOK$' ;;
          *) cmd=GETPIN re=$'^OK[^\n]*\nOK\nD ([^\n]*)\nOK$' ;;
        esac
        out=$(${pinentry} <<EOF
        SETDESC $desc
        $cmd
        EOF
        )
        [[ $out =~ $re ]] || exit 1
        pin=''${BASH_REMATCH[1]-}
        [[ $cmd == CONFIRM ]] || printf '%s\n' "''${pin//%25/%}"
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
