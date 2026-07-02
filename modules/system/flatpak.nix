# @desc: Flatpak
{...}: {
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
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        # Verified packages
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
          #org.gnome.Mahjongg
          #com.github.finefindus.eyedropper
          dev.bragefuglseth.Fretboard
          # com.rafaelmardojai.Blanket
          org.mozilla.Thunderbird
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

        # Unverified packages
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
        flatpak uninstall -y --noninteractive --unused || true

        # Overrides
        flatpak override --socket=wayland
        flatpak override --nosocket=x11
        flatpak override --env=SIGNAL_PASSWORD_STORE=gnome-libsecret org.signal.Signal
        flatpak override --env=ELECTRON_OZONE_PLATFORM_HINT=wayland

        # Share the stylix GTK theme (highlight accent) with flatpaks; gtk.css and the Obsidian vault symlink into /nix/store.
        flatpak override --filesystem=xdg-config/gtk-3.0:ro
        flatpak override --filesystem=xdg-config/gtk-4.0:ro
        flatpak override --filesystem=/nix/store:ro
      '';
      # needs network, /var writes, and bwrap user namespaces.
      serviceConfig =
        hardening.base
        // {
          Type = "oneshot";
          RemainAfterExit = true;
        };
    };
    # Fix xdg-open in flatpak; include the user profile so the portal can
    # launch home-manager-installed apps (e.g. firefox) for URL handlers.
    systemd.user.extraConfig = ''
      DefaultEnvironment="PATH=/etc/profiles/per-user/liana/bin:/run/current-system/sw/bin"
    '';
  };
}
