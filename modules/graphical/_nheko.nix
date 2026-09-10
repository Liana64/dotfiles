# @desc: nheko — Matrix Qt client, bwrap-jailed (GUI counterpart to iamb)
{...}: {
  flake.modules.homeManager.nheko = {
    config,
    inputs,
    lib,
    pkgs,
    ...
  }: let
    # nheko still links libolm, which nixpkgs marks insecure. Confine the
    # exception to this closure instead of the whole home nixpkgs config; a
    # version bump breaks eval loudly rather than silently widening it.
    inherit
      (import inputs.nixpkgs {
        inherit (pkgs) system;
        config.permittedInsecurePackages = ["olm-3.2.16"];
      })
      nheko
      ;

    # nheko keeps the access token and device id in nheko.conf, so the file has
    # to stay writable: seed the preferences once instead of linking the store.
    seed = (pkgs.formats.ini {}).generate "nheko.conf" {
      user = {
        theme = "system";
        font_family = config.stylix.fonts.sansSerif.name;
        emoji_font_family = config.stylix.fonts.emoji.name;
        font_size = config.stylix.fonts.sizes.applications;

        desktop_notifications = true;
        alert_on_notification = false;
        decrypt_notifications = true;
        decrypt_sidebar = true;
        space_notifications = true;

        read_receipts = true;
        typing_notifications = true;
        markdown_enabled = true;

        group_view = true;
        sort_by_unread = true;
        sort_by_alphabet = false;
        scrollbars_in_roomlist = false;
        avatar_circles = true;
        use_identicon = true;

        bubbles_enabled = false;
        small_avatars_enabled = false;
        animate_images_on_hover = false;
        fancy_effects = false;
        open_image_external = false;
        open_video_external = false;
        expose_dbus_api = false;

        "timeline\\buttons" = true;
        "timeline\\message_hover_highlight" = true;
        "timeline\\enlarge_emoji_only_msg" = true;

        "window\\tray" = true;
        "window\\start_in_tray" = false;
      };
    };

    conf = "${config.xdg.configHome}/nheko/nheko.conf";

    xdgOpenShim = pkgs.writeShellScriptBin "xdg-open" ''
      exec ${lib.getExe' pkgs.glib "gdbus"} call --session \
        --dest org.freedesktop.portal.Desktop \
        --object-path /org/freedesktop/portal/desktop \
        --method org.freedesktop.portal.OpenURI.OpenURI "" "$1" "{}"
    '';
  in {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "nheko-jail";
        paths = [(pkgs.writeShellScriptBin "nheko" (builtins.readFile ../bin/nheko))];
        buildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/nheko \
            --prefix PATH : ${lib.makeBinPath [pkgs.bubblewrap pkgs.xdg-dbus-proxy]} \
            --set NHEKO_BIN ${lib.getExe nheko} \
            --set XDG_OPEN_SHIM ${xdgOpenShim}/bin
        '';
      })
    ];

    xdg.desktopEntries.nheko = {
      name = "nheko";
      genericName = "Matrix client";
      exec = "nheko %u";
      icon = "${nheko}/share/icons/hicolor/scalable/apps/nheko.svg";
      categories = ["Network" "InstantMessaging"];
      mimeType = ["x-scheme-handler/matrix"];
      settings.StartupWMClass = "nheko";
    };

    home.activation.nhekoSeed = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ ! -e "${conf}" ]; then
        mkdir -p "$(dirname "${conf}")"
        install -m600 ${seed} "${conf}"
      fi
    '';
  };
}
