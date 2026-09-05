# @desc: Thunderbird
{...}: {
  flake.modules.homeManager.thunderbird = {colors, ...}: let
    # Flatpak Thunderbird profile; symlinks resolve in-sandbox via the /nix/store grant in flatpak.nix.
    profile = ".var/app/org.mozilla.thunderbird/.thunderbird/rciub5to.default-esr";
    selection = ''
      ::selection {
        background-color: ${colors.highlight} !important;
        color: ${colors.darker} !important;
      }
    '';
  in {
    home.file."${profile}/user.js".text = ''
      user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
      // Render at the exact fractional output scale (1.8) instead of 2x-then-downscale, which blurs text.
      user_pref("widget.wayland.fractional-scale.enabled", true);
    '';

    home.file."${profile}/chrome/userChrome.css".text = ''
      #threadTree tr.selected,
      #threadTree tr.selected td {
        background-color: ${colors.highlightDim} !important;
      }

      #threadTree:focus-within tr.selected,
      #threadTree:focus-within tr.selected td {
        background-color: ${colors.highlight} !important;
      }

      #threadTree tr.selected,
      #threadTree tr.selected td,
      #threadTree tr.selected .subject {
        color: ${colors.darker} !important;
      }

      #folderPaneWriteMessage {
        color: ${colors.white} !important;
      }

      /* Today/selected calendar headings default to AccentColor, which the GTK dark theme
         resolves to a near-background gray. */
      .day-column-today .day-column-heading,
      .day-column-selected .day-column-heading,
      calendar-day-label[relation="today"] {
        color: ${colors.highlight} !important;
      }

      ${selection}
    '';

    home.file."${profile}/chrome/userContent.css".text = selection;
  };
}
