{ pkgs, ... }: {
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    #forcePageTableIsolation = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true; # Monitor with journalctl -u apparmor
      packages = [pkgs.apparmor-profiles];
    };
  };

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

      #if [ -f "$STAMP" ]; then
      #  exit 0
      #fi

      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

      # Verified packages
      flatpak install -y --noninteractive flathub \
      org.signal.Signal \
      org.gnome.Calculator \
      org.gnome.Loupe \
      org.gnome.Maps \
      org.gnome.TextEditor \
      org.gimp.GIMP \
      org.libreoffice.LibreOffice \
      md.obsidian.Obsidian \
      org.mozilla.Thunderbird \
      com.moonlight_stream.Moonlight \
      org.localsend.localsend_app \
      dev.vencord.Vesktop \
      io.github.ungoogled_software.ungoogled_chromium \
      org.pulseaudio.pavucontrol \
      com.bitwarden.desktop \
      com.rustdesk.RustDesk \
      com.github.tchx84.Flatseal

      #com.prusa3d.PrusaSlicer \
      #com.github.johnfactotum.Foliate \
      #org.freecad.FreeCAD \

      # org.telegram.desktop
      # org.zulip.Zulip

      # Unverified packages
      flatpak install -y --noninteractive flathub \
      org.videolan.VLC \
      me.proton.Mail \
      us.zoom.Zoom

      #org.zotero.Zotero


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
