# @desc: Default applications per MIME type
{...}: {
  flake.modules.homeManager.mime = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        # Web
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";

        # Zoom → web client (Firefox)
        "x-scheme-handler/zoommtg" = "zoom-web.desktop";
        "x-scheme-handler/zoomus" = "zoom-web.desktop";

        # Terminal
        "x-scheme-handler/terminal" = "kitty.desktop";

        # PDF — firefox renders these well enough
        "application/pdf" = "firefox.desktop";

        # Plain text
        "text/plain" = "org.gnome.TextEditor.desktop";

        # Images → Loupe
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/bmp" = "org.gnome.Loupe.desktop";
        "image/tiff" = "org.gnome.Loupe.desktop";

        # Video → Showtime
        "video/mp4" = "org.gnome.Showtime.desktop";
        "video/mpeg" = "org.gnome.Showtime.desktop";
        "video/quicktime" = "org.gnome.Showtime.desktop";
        "video/webm" = "org.gnome.Showtime.desktop";
        "video/x-matroska" = "org.gnome.Showtime.desktop";
        "video/x-msvideo" = "org.gnome.Showtime.desktop";
      };
      associations.removed = {
        "text/html" = "chromium-browser.desktop";
        "x-scheme-handler/http" = "chromium-browser.desktop";
        "x-scheme-handler/https" = "chromium-browser.desktop";
        "application/pdf" = "chromium-browser.desktop";
      };
    };
  };
}
