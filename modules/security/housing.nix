# @desc: nix-housing sandbox domains
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
    hardening,
    ...
  }: let
    mix = import ../_lib/mix.nix lib;

    accents = {
      vault = "#9254de";
      dev = "#4b9bff";
      infra = "#49aa19";
      personal = "#d4b106";
      web = "#d87a16";
      web-public = "#cb2b83";
      web-ephemeral = "#8bbb11";
      web-gemini = "#d95216";
      untrusted = "#dc4446";
      agentic = "#13a8a8";
      media = "#597ef7";
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

    portalOpen = pkgs.writeShellScript "portal-open" ''
      exec ${lib.getExe' pkgs.systemd "busctl"} --user --quiet call \
        org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
        org.freedesktop.portal.OpenURI OpenURI 'ssa{sv}' "" "$1" 0
    '';
    portalUrls = {
      xdg.desktopEntries.portal-open = {
        name = "Open on host";
        noDisplay = true;
        exec = "${portalOpen} %u";
        mimeType = ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"];
      };
      xdg.configFile."mimeapps.list".force = true;
      xdg.mimeApps = {
        enable = true;
        defaultApplications =
          lib.genAttrs ["text/html" "x-scheme-handler/http" "x-scheme-handler/https"] (_: "portal-open.desktop")
          // lib.genAttrs ["x-scheme-handler/mailto" "x-scheme-handler/mid" "message/rfc822"] (_: "thunderbird.desktop")
          // {"x-scheme-handler/discord" = "vesktop.desktop";};
      };
    };

    portalOpenFile = pkgs.writeShellScript "portal-open-file" ''
      exec 3<"$1"
      exec ${lib.getExe' pkgs.systemd "busctl"} --user --quiet call \
        org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop \
        org.freedesktop.portal.OpenURI OpenFile 'sha{sv}' "" 3 0
    '';
    portalPdf = {
      xdg.desktopEntries.portal-open-file = {
        name = "Open file on host";
        noDisplay = true;
        exec = "${portalOpenFile} %f";
        mimeType = ["application/pdf"];
      };
      xdg.mimeApps.defaultApplications."application/pdf" = "portal-open-file.desktop";
      programs.thunderbird.profiles.default.settings."pdfjs.disabled" = true;
    };

    pdfHouse = "web-ephemeral";
    openPdf = let
      h = config.housing.houses.${pdfHouse};
    in
      intake.openPdf {
        name = "open-pdf";
        launch = "${h.runner}/bin/house-${pdfHouse} ${h.hm.homeManagerConfiguration.config.home.path}/bin/firefox --new-tab";
      };

    projects = "$NIX_HOUSING_REAL_HOME/Projects";
    notebook = "$NIX_HOUSING_REAL_HOME/Notebook";
    dillo = "$NIX_HOUSING_REAL_HOME/.dillo";
    drop = "$NIX_HOUSING_REAL_HOME/houses/shared/drop";
    velesDir = "$NIX_HOUSING_REAL_HOME/houses/shared/veles";

    intake = import ../_lib/house-intake.nix {inherit pkgs lib hardening config;};

    sharedDrop = let
      shared = "${config.home.homeDirectory}/houses/shared/drop";
    in
      {config, ...}: {
        xdg.configFile."gtk-3.0/bookmarks".text = "file://${shared} Shared\n";
        programs.firefox.policies.DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
      };

    webCapabilities = {
      gui.enable = true;
      gpu.enable = true;
      pulseAudio.enable = true;
      namespacing.proc = true;
      sessionDbus.own = ["org.mozilla.firefox.*"];
      landlock = {
        connectTcpPorts = [53 80 443 8006 8443];
        rwDirs = [drop];
      };
    };
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
              portalUrls
              portalPdf
              sharedDrop
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
          sessionDbus.talk = ["org.freedesktop.portal.*" "org.freedesktop.Notifications" "org.freedesktop.secrets" "org.kde.StatusNotifierWatcher"];
          sessionDbus.own = ["org.freedesktop.StatusNotifierItem-2-1"];
          landlock = {
            connectTcpPorts = [443 1025 1143 6697];
            rwDirs = [notebook drop "/dev/shm"];
          };
        };
      };

      web-gemini = {
        hm.config.imports =
          base
          ++ [
            houseTitle
            sharedDrop
            aspects.dillo
          ];
        exportDesktopEntries = true;
        capabilities = {
          gui.enable = true;
          gpu.enable = true;
          pulseAudio.enable = true;
          namespacing.proc = true;
          landlock = {
            connectTcpPorts = [53 80 443];
            rwDirs = [drop dillo];
          };
        };
      };

      web = {
        hm.config.imports =
          base
          ++ [
            houseTitle
            sharedDrop
            aspects.chromium
            aspects.firefox
          ];
        exportDesktopEntries = true;
        capabilities = lib.recursiveUpdate webCapabilities {
          landlock.deviceFiles = map (n: "/dev/hidraw${toString n}") (lib.range 0 15);
        };
      };

      web-public = {
        hm.config = {
          imports =
            base
            ++ [
              houseTitle
              sharedDrop
              aspects.firefox
              aspects.zoom
            ];
          firefox.role = "public";
        };
        exportDesktopEntries = true;
        capabilities = lib.recursiveUpdate webCapabilities {
          sessionDbus.talk = ["org.freedesktop.Notifications"];
          landlock.deviceFiles = ["/dev/video0" "/dev/video1"];
        };
      };

      web-ephemeral = {
        hm.config = {
          imports =
            base
            ++ [
              houseTitle
              sharedDrop
              aspects.firefox
            ];
          firefox.role = "ephemeral";
        };
        exportDesktopEntries = true;
        capabilities = lib.recursiveUpdate webCapabilities {
          landlock.roDirs = ["$NIX_HOUSING_REAL_XDG_RUNTIME_DIR/${intake.pdfStage}"];
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
            bindTcpPorts = [0];
            roFiles = ["/var/secrets/eek/gateway-key"];
            rwDirs = [drop velesDir];
            # fixed-output derivations fetch daemon-side, outside landlock — the 443 limit is not an exfiltration boundary
            socketFiles = ["/nix/var/nix/daemon-socket/socket"];
          };
        };
      };

      media = {
        hm.config = {config, ...}: {
          imports = base ++ [houseTitle aspects.fooyin];
          home.file.Music.source = config.lib.file.mkOutOfStoreSymlink "/mnt/m1/media/Music";
        };
        exportDesktopEntries = true;
        capabilities = {
          gui.enable = true;
          gpu.enable = true;
          pulseAudio.enable = true;
          namespacing.proc = true;
          sessionDbus.own = ["org.mpris.MediaPlayer2.fooyin"];
          landlock.rwDirs = ["/mnt/m1/media"];
        };
      };

      untrusted = {
        hm.config.imports = [terminfo houseTitle sharedDrop];
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

    systemd.user.services."house-promote@" = {
      Unit.Description = "Copy pending %i house files into the host";
      Service = intake.service {mode = "promote";};
    };

    systemd.user.services."house-dismiss@" = {
      Unit.Description = "Mark pending %i house files as seen";
      Service = intake.service {mode = "dismiss";};
    };

    systemd.user.tmpfiles.rules =
      [
        "d %h/houses/shared 0700 - - -"
        "d %h/houses/shared/drop 0700 - - -"
        "d %h/houses/shared/veles 0700 - - -"
        "d %t/${intake.pdfStage} 0700 - - -"
      ]
      ++ lib.concatMap (h: map (d: "d %h/${d}/${h} 0700 - - -") intake.dirs ++ ["d %S/house-intake/${h} 0700 - - -"]) intake.houses;

    xdg.desktopEntries =
      lib.mapAttrs' (name: _:
        lib.nameValuePair "house-${name}" {
          name = "kitty [${name}]";
          genericName = "Terminal";
          comment = "Login shell inside the ${name} house";
          icon = "kitty";
          exec = "${lib.getExe pkgs.kitty} --class house-${name} ${config.housing.houses.${name}.runner}/bin/house-${name}";
          categories = ["System" "TerminalEmulator"];
        })
      accents
      // {
        open-pdf = {
          name = "PDF [${pdfHouse}]";
          noDisplay = true;
          exec = "${lib.getExe openPdf} %f";
          mimeType = ["application/pdf"];
        };
      };

    xdg.dataFile =
      lib.genAttrs (map (app: "applications/${app}.desktop") ["chromium-browser" "firefox" "dillo" "iamb" "obsidian" "org.squidowl.halloy" "signal" "thunderbird" "vesktop" "zoom-web"]) (_: {
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
