# @desc: Thunderbird
{...}: {
  flake.modules.homeManager.thunderbird = {
    colors,
    nixpkgs-unstable,
    ...
  }: let
    selection = ''
      ::selection {
        background-color: ${colors.highlight} !important;
        color: ${colors.darker} !important;
      }
    '';
  in {
    programs.thunderbird = {
      enable = true;
      package = nixpkgs-unstable.thunderbird;

      profiles.default = {
        isDefault = true;

        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          # Render at the exact fractional output scale (1.8) instead of 2x-then-downscale, which blurs text.
          "widget.wayland.fractional-scale.enabled" = true;
        };

        userChrome = ''
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

        userContent = selection;
      };
    };
  };
}
