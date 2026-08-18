# @desc: Flatpak
{...}: {
  flake.modules.homeManager.flatpak = {lib, ...}: let
    overrides = {
      "com.bitwarden.desktop".Context = {
        sockets = "!x11";
        devices = "!all";
        filesystems = "!~/.mozilla;~/.mozilla/native-messaging-hosts:create;!~/.var/app/org.mozilla.firefox/.mozilla;!xdg-config/chromium/NativeMessagingHosts;!xdg-config/google-chrome/NativeMessagingHosts;!xdg-config/microsoft-edge/NativeMessagingHosts;!~/.var/app/org.chromium.Chromium/config/chromium/NativeMessagingHosts;!~/.var/app/com.google.Chrome/config/google-chrome/NativeMessagingHosts;!~/.var/app/com.microsoft.Edge/config/microsoft-edge/NativeMessagingHosts";
      };
      "com.moonlight_stream.Moonlight".Context.devices = "!all;dri;input";
      "com.rustdesk.RustDesk".Context.filesystems = "!home;xdg-download";
      "dev.vencord.Vesktop".Context.filesystems = "!~/.steam";
      "io.github.ungoogled_software.ungoogled_chromium".Context.devices = "!all;dri";
      "md.obsidian.Obsidian".Context.filesystems = "!home;!/mnt;!/media;!/run/media;!xdg-run/gnupg;~/Notebook";
      "me.proton.Mail".Context.devices = "!all;dri";
      "net.supercellwx.app".Context = {
        sockets = "!x11";
        devices = "!all;dri";
        filesystems = "!xdg-documents";
      };
      "org.gimp.GIMP".Context.devices = "!all;dri";
      "org.mozilla.thunderbird_esr".Context = {
        devices = "!all;dri";
        features = "!devel";
      };
      "org.gnome.Calculator".Context.sockets = "!fallback-x11;!x11";
      "org.gnome.Calendar".Context.sockets = "!fallback-x11;!x11";
      "org.gnome.Snapshot".Context.sockets = "!fallback-x11;!x11";
      "org.pulseaudio.pavucontrol" = {
        Context.sockets = "!fallback-x11;!x11";
        Environment."PULSE_PROP_media.category" = "";
      };
    };
  in {
    xdg.dataFile = lib.mapAttrs' (app: sections:
      lib.nameValuePair "flatpak/overrides/${app}" {
        text = lib.generators.toINI {} sections;
      })
    overrides;
  };

  flake.modules.nixos.flatpak = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # flatpaks are pretty good at sandboxing, so we ought to use them when available
    services.flatpak = {
      enable = true;
    };

    systemd.services.flatpak-repo = {
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "nss-lookup.target"];
      wants = ["network-online.target" "nss-lookup.target"];
      path = [pkgs.flatpak pkgs.gawk];
      script = ''
        flatpak override --socket=wayland
        flatpak override --nosocket=x11
        flatpak override --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal
        flatpak override --env=ELECTRON_OZONE_PLATFORM_HINT=wayland
        flatpak override --filesystem=xdg-config/gtk-3.0:ro
        flatpak override --filesystem=xdg-config/gtk-4.0:ro
        flatpak override --filesystem=/nix/store:ro

        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        flatpak remote-add --if-not-exists supercell-wx https://dpaulat.github.io/supercell-wx/supercell-wx.flatpakrepo

        verified=(
          org.signal.Signal
          org.gnome.Calculator
          org.gnome.Showtime
          org.gnome.Loupe
          org.gnome.Maps
          org.gnome.TextEditor
          org.gnome.Snapshot
          org.gnome.Characters
          org.gnome.Calendar
          dev.bragefuglseth.Fretboard
          org.mozilla.thunderbird_esr
          org.gimp.GIMP
          org.libreoffice.LibreOffice
          org.localsend.localsend_app
          org.pulseaudio.pavucontrol
          com.moonlight_stream.Moonlight
          com.bitwarden.desktop
          com.rustdesk.RustDesk
          com.github.tchx84.Flatseal
          dev.vencord.Vesktop
          md.obsidian.Obsidian
          io.github.ungoogled_software.ungoogled_chromium
          com.todoist.Todoist
          # com.prusa3d.PrusaSlicer
          # com.github.johnfactotum.Foliate
          # org.freecad.FreeCAD
          # org.telegram.desktop
          # org.zulip.Zulip
        )

        unverified=(
          me.proton.Mail
        )

        desired=( "''${verified[@]}" "''${unverified[@]}" )

        installed=$(flatpak list --app --columns=application,origin | awk '$2 == "flathub" { print $1 }')
        for app in $installed; do
          keep=0
          for d in "''${desired[@]}"; do
            if [ "$app" = "$d" ]; then keep=1; break; fi
          done
          if [ "$keep" -eq 0 ]; then
            flatpak uninstall -y --noninteractive "$app" || true
          fi
        done

        flatpak install -y --noninteractive flathub "''${desired[@]}"
        for app in "''${desired[@]}"; do
          flatpak update -y --noninteractive "$app" || true
        done
        flatpak install -y --noninteractive supercell-wx net.supercellwx.app
        flatpak update -y --noninteractive net.supercellwx.app || true
        flatpak update -y --noninteractive --runtime || true
        flatpak uninstall -y --noninteractive --unused || true
      '';
      unitConfig = {
        StartLimitIntervalSec = 3600;
        StartLimitBurst = 10;
      };
      serviceConfig =
        hardening.base
        // {
          Type = "oneshot";
          Restart = "on-failure";
          RestartSec = 120;
        };
    };

    systemd.timers.flatpak-repo = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "30min";
      };
    };

    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/etc/profiles/per-user/liana/bin:/run/current-system/sw/bin"
    '';
  };
}
