{ colors, ... }:
let
  # Flatpak Thunderbird ESR profile; symlinks resolve in-sandbox via the /nix/store grant in flatpak.nix.
  profile = ".var/app/org.mozilla.Thunderbird/.thunderbird/rciub5to.default-esr";
  selection = ''
    ::selection {
      color: ${colors.white} !important;
    }
  '';
in
{
  home.file."${profile}/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
  '';

  home.file."${profile}/chrome/userChrome.css".text = ''
    #threadTree tr.selected,
    #threadTree tr.selected td,
    #threadTree tr.selected .subject {
      color: ${colors.white} !important;
    }

    ${selection}
  '';

  home.file."${profile}/chrome/userContent.css".text = selection;
}
