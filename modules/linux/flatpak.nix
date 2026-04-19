{ pkgs, ... }: {
  # flatpaks are pretty good at sandboxing, so we ought to use them when available
  services.flatpak = {
    enable = true;
  };

  # TODO: Declare this: flatpak override --user --socket=wayland
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      STAMP="/var/lib/flatpak/.nixos-setup-done"

      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

      # Verified packages
      verified=(
        org.signal.Signal
        org.gnome.Calculator
        org.gnome.Loupe
        org.gnome.Maps
        org.gnome.TextEditor
        org.gnome.Snapshot
        org.gnome.Characters
        org.gnome.Calendar
        org.gnome.Mahjongg
        com.github.finefindus.eyedropper
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
        # com.prusa3d.PrusaSlicer
        # com.github.johnfactotum.Foliate
        # org.freecad.FreeCAD
        # org.telegram.desktop
        # org.zulip.Zulip
      )

      # Unverified packages
      unverified=(
        org.videolan.VLC
        me.proton.Mail
        us.zoom.Zoom
      )

      flatpak install -y --noninteractive flathub "''${verified[@]}"
      flatpak install -y --noninteractive flathub "''${unverified[@]}"

      touch "$STAMP"
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
  # Fix xdg-open in flatpak; include the user profile so the portal can
  # launch home-manager-installed apps (e.g. firefox) for URL handlers.
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/etc/profiles/per-user/liana/bin:/run/current-system/sw/bin"
  '';
}
