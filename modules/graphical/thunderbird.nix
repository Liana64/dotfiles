# @desc: Thunderbird
{...}: {
  flake.modules.homeManager.thunderbird = {colors, ...}: let
    # Flatpak Thunderbird ESR profile; symlinks resolve in-sandbox via the /nix/store grant in flatpak.nix.
    profile = ".var/app/org.mozilla.Thunderbird/.thunderbird/rciub5to.default-esr";
    selection = ''
      ::selection {
        background-color: ${colors.highlight} !important;
        color: ${colors.white} !important;
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
      #threadTree tr.selected td,
      #threadTree tr.selected .subject {
        color: ${colors.white} !important;
      }

      #folderPaneWriteMessage {
        color: ${colors.white} !important;
      }

      ${selection}
    '';

    home.file."${profile}/chrome/userContent.css".text = selection;
  };
}
