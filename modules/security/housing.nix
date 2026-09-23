# @desc: nix-housing domains — sandboxed home environments (vault, dev, infra, personal, web, agentic, untrusted)
{config, ...}: let
  aspects = config.flake.modules.homeManager;
  terminfo = {pkgs, ...}: {home.packages = [pkgs.kitty.terminfo];};
  base = with aspects; [aliases atuin shell starship theme terminfo];
in {
  flake.modules.homeManager.housing = {
    inputs,
    config,
    lib,
    pkgs,
    colors,
    ...
  }: let
    mix = import ../_lib/mix.nix lib;
    hardening = import ../_lib/systemd-hardening.nix;

    accents = {
      vault = "#9254de";
      dev = "#4b9bff";
      infra = "#49aa19";
      personal = "#d4b106";
      web = "#d87a16";
      untrusted = "#dc4446";
      agentic = "#13a8a8";
    };

    houseTitle = {
      programs.zsh = {
        enable = true;
        initContent = lib.mkAfter ''
          house-title() { print -Pn '\e]2;%~\a'; }
          house-title-exec() { print -n "\e]2;''${1}\a"; }
          autoload -Uz add-zsh-hook
          add-zsh-hook precmd house-title
          add-zsh-hook preexec house-title-exec
        '';
      };
    };

    # GNUPGHOME must be non-default in-house: only then does gnupg fall back to homedir sockets when landlock denies /run/user/<uid>/gnupg
    vaultGnupg = "${config.home.homeDirectory}/houses/vault/gnupg";
    vaultExtraSocket = "${vaultGnupg}/S.gpg-agent.extra";
    vaultSshSocket = "${vaultGnupg}/S.gpg-agent.ssh";

    gpgClient = {config, ...}: {
      programs.gpg = {
        enable = true;
        homedir = "${config.home.homeDirectory}/gnupg";
        settings.no-autostart = true;
        mutableKeys = false;
        mutableTrust = false;
        publicKeys = [
          {
            source = pkgs.writeText "pub.asc" (import ../_lib/keys.nix).lianaGpg;
            trust = "ultimate";
          }
        ];
      };
      home.file."gnupg/S.gpg-agent" = {
        source = config.lib.file.mkOutOfStoreSymlink vaultExtraSocket;
        force = true;
      };
      home.sessionVariables.SSH_AUTH_SOCK = vaultSshSocket;
    };

    vaultClientGrants = {
      socketFiles = [vaultExtraSocket vaultSshSocket];
    };

    focused = config.wayland.windowManager.sway.config.colors.focused;
    swaymsg = lib.getExe' config.wayland.windowManager.sway.package "swaymsg";
    client = c: "${c.border} ${c.background} ${c.text} ${c.indicator} ${c.childBorder}";
    tint = accent: let t = mix colors.gray accent 20; in "${t} ${t} ${focused.text} ${t} ${t}";
    tints =
      lib.mapAttrs' (name: accent: lib.nameValuePair "house-${name}" (tint accent)) accents
      // {"" = client focused;};
    houseTint = pkgs.writeShellScript "house-tint" ''
      ${swaymsg} -t subscribe -m '["window"]' \
        | ${lib.getExe pkgs.jq} --unbuffered -r --argjson tints ${lib.escapeShellArg (builtins.toJSON tints)} \
            'select(.change == "focus") | $tints[.container.sandbox_app_id // .container.app_id // ""] // $tints[""]' \
        | while read -r colors; do ${swaymsg} -q "client.focused $colors"; done
    '';

    projects = "$NIX_HOUSING_REAL_HOME/Projects";
    drop = "$NIX_HOUSING_REAL_HOME/houses/shared/drop";
    velesDir = "$NIX_HOUSING_REAL_HOME/houses/shared/veles";
  in {
    imports = [inputs.nix-housing.homeManagerModules.default];

    housing.enable = true;
    housing.shellPromptPrefix = false;
    housing.houses = {
      vault = {
        hm.config = {config, ...}: {
          imports = [aspects.gpg terminfo houseTitle];
          programs.gpg.homedir = "${config.home.homeDirectory}/gnupg";
          services.gpg-agent.pinentry.package = pkgs.pinentry-qt;
        };
        capabilities = {
          wayland.enable = true;
          landlock.socketDirs = ["/run/pcscd" "/var/run/pcscd"];
        };
      };

      dev = {
        hm.config.imports =
          base
          ++ [
            houseTitle
            gpgClient
            aspects.agentic
            aspects.cliPackages
            aspects.devPackages
            aspects.dvcs
            aspects.helix
            aspects.veles
          ];
        capabilities.namespacing.proc = true;
        capabilities.landlock =
          vaultClientGrants
          // {
            connectTcpPorts = [22 443];
            bindTcpPorts = [0];
            roFiles = ["/var/secrets/eek/gateway-key"];
            rwDirs = [projects drop velesDir];
          };
      };

      infra = {
        hm.config.dconf.enable = false;
        hm.config.imports =
          base
          ++ [
            houseTitle
            gpgClient
            aspects.devPackages
            aspects.infra
            aspects.k9s
            aspects.netshoot
            aspects.ssh
            aspects.stylix
            aspects.veles
          ];
        capabilities.landlock =
          vaultClientGrants
          // {
            connectTcpPorts = [22 6443];
            rwDirs = [projects drop velesDir];
          };
      };

      personal = {
        hm.config = {
          imports =
            base
            ++ [
              houseTitle
              aspects.halloy
              aspects.iamb
              aspects.obsidian
              aspects.signal
              aspects.thunderbird
              aspects.vesktop
            ];
          home.sessionVariables = {
            NIXOS_OZONE_WL = "1";
            XDG_SESSION_TYPE = "wayland";
          };
        };
        exportDesktopEntries = true;
        capabilities = {
          gui.enable = true;
          gpu.enable = true;
          pulseAudio.enable = true;
          namespacing.proc = true;
          sessionDbus.talk = ["org.freedesktop.portal.*" "org.freedesktop.Notifications" "org.freedesktop.secrets"];
          landlock = {
            connectTcpPorts = [443 1025 1143 6697];
            rwDirs = [drop "/dev/shm"];
          };
        };
      };

      web = {
        hm.config.imports =
          base
          ++ [
            houseTitle
            aspects.chromium
            aspects.firefox
            aspects.zoom
          ];
        exportDesktopEntries = true;
        capabilities = {
          gui.enable = true;
          gpu.enable = true;
          pulseAudio.enable = true;
          namespacing.proc = true;
          landlock = {
            connectTcpPorts = [53 80 443];
            deviceFiles = ["/dev/video0" "/dev/video1"];
            rwDirs = [drop];
          };
        };
      };

      agentic = {
        hm.config.imports =
          base
          ++ [
            houseTitle
            aspects.agentic
            aspects.cliPackages
            aspects.devPackages
            aspects.helix
            aspects.veles
          ];
        capabilities = {
          namespacing.proc = true;
          landlock = {
            connectTcpPorts = [443];
            roFiles = ["/var/secrets/eek/gateway-key"];
            rwDirs = [drop velesDir];
            # fixed-output derivations fetch daemon-side, outside landlock — the 443 limit is not an exfiltration boundary
            socketFiles = ["/nix/var/nix/daemon-socket/socket"];
          };
        };
      };

      untrusted = {
        hm.config.imports = [terminfo houseTitle];
        capabilities = {
          gui.enable = true;
          gpu.enable = true;
          pulseAudio.enable = true;
          landlock.rwDirs = [drop];
        };
      };
    };

    systemd.user.services.vault-agent = {
      Unit.Description = "gpg-agent inside the vault house";
      Service = {
        ExecStart = "${config.housing.houses.vault.runner}/bin/house-vault ${pkgs.gnupg}/bin/gpg-agent --daemon --no-detach";
        Restart = "on-failure";
      };
      Unit.After = ["graphical-session.target"];
      Install.WantedBy = ["graphical-session.target"];
    };

    systemd.user.tmpfiles.rules = [
      "d %h/houses/shared 0700 - - -"
      "d %h/houses/shared/drop 0700 - - -"
      "d %h/houses/shared/veles 0700 - - -"
    ];

    xdg.desktopEntries = lib.mapAttrs' (name: _:
      lib.nameValuePair "house-${name}" {
        name = "kitty [${name}]";
        genericName = "Terminal";
        comment = "Login shell inside the ${name} house";
        icon = "kitty";
        exec = "${lib.getExe pkgs.kitty} --class house-${name} ${config.housing.houses.${name}.runner}/bin/house-${name}";
        categories = ["System" "TerminalEmulator"];
      })
    accents;

    xdg.dataFile =
      lib.genAttrs (map (app: "applications/${app}.desktop") ["firefox" "iamb" "obsidian" "org.squidowl.halloy" "signal" "ungoogled-chromium" "thunderbird" "vesktop" "zoom-web"]) (_: {
        text = ''
          [Desktop Entry]
          Type=Application
          Hidden=true
        '';
      })
      // {
        "applications/iamb.house-personal.desktop".text = ''
          [Desktop Entry]
          Type=Application
          Name=iamb [personal]
          GenericName=Matrix Client [personal]
          Icon=iamb
          Categories=Network;InstantMessaging;Chat;
          Exec=${lib.getExe pkgs.kitty} --class house-personal --title iamb ${config.housing.houses.personal.runner}/bin/house-personal iamb
        '';
      };

    wayland.windowManager.sway.config.window.commands = lib.concatLists (lib.mapAttrsToList (name: _: [
        {
          criteria.sandbox_app_id = "house-${name}";
          command = ''title_format "[${name}] %title"'';
        }
        {
          criteria.app_id = "^house-${name}$";
          command = ''title_format "[${name}] %title"'';
        }
      ])
      accents);

    systemd.user.services.house-tint = lib.mkIf config.wayland.windowManager.sway.enable {
      Unit = {
        Description = "Per-house titlebar tint";
        After = ["graphical-session.target"];
        Requisite = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Install.WantedBy = ["graphical-session.target"];
      Service =
        hardening.confined
        // {
          ExecStart = "${houseTint}";
          Restart = "on-failure";
          ProtectHome = "read-only";
        };
    };
  };
}
