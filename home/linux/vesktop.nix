# Recolors the Vesktop (flatpak) Discord client from the stylix palette via Vencord QuickCSS.
{ config, ... }: let
  inherit (config.lib.stylix.colors.withHashtag)
    base00 base01 base03 base04 base05 base07 base08 base0A base0B base0D;
in {
  home.file.".var/app/dev.vencord.Vesktop/config/vesktop/settings/quickCss.css" = {
    force = true;
    text = ''
      .theme-dark {
        --background-primary: ${base01};
        --background-secondary: ${base00};
        --background-secondary-alt: ${base00};
        --background-tertiary: ${base00};
        --background-accent: ${base01};
        --background-floating: ${base00};
        --background-mobile-primary: ${base01};
        --background-mobile-secondary: ${base00};
        --channeltextarea-background: ${base00};
        --activity-card-background: ${base00};

        --bg-base-primary: ${base01};
        --bg-base-secondary: ${base00};
        --bg-base-tertiary: ${base00};
        --bg-base-lower: ${base00};
        --bg-surface-overlay: ${base00};

        --text-normal: ${base05};
        --text-default: ${base05};
        --text-muted: ${base03};
        --text-faint: ${base03};
        --header-primary: ${base07};
        --header-secondary: ${base04};
        --channels-default: ${base04};
        --channel-icon: ${base03};

        --interactive-normal: ${base04};
        --interactive-hover: ${base05};
        --interactive-active: ${base07};
        --interactive-muted: ${base03};

        --text-link: ${base0D};
        --text-link-low-saturation: ${base0D};
        --mention-foreground: ${base0D};
        --mention-background: ${base0D}1f;
        --background-mentioned: ${base0D}14;
        --background-mentioned-hover: ${base0D}1f;

        --status-online: ${base0B};
        --status-idle: ${base0A};
        --status-dnd: ${base08};
        --status-streaming: ${base0D};
        --status-speaking: ${base0B};
      }

      :root {
        --brand-experiment: ${base0D};
        --brand-experiment-500: ${base0D};
        --brand-experiment-560: color-mix(in srgb, ${base0D}, black 12%);
        --brand-experiment-600: color-mix(in srgb, ${base0D}, black 22%);
        --brand-experiment-630: color-mix(in srgb, ${base0D}, black 30%);
        --brand-500: ${base0D};
        --brand-560: color-mix(in srgb, ${base0D}, black 12%);
        --brand-600: color-mix(in srgb, ${base0D}, black 22%);
      }

      ::selection {
        background-color: ${base0D}59;
      }
    '';
  };
}
