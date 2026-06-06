{
  pkgs,
  inputs,
  config,
  colors,
  ...
}: let
  stylixColors = config.lib.stylix.colors;
  indigo = "#${stylixColors.base0D}";
  white  = "#${stylixColors.base07}";
in {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    profiles.liana = {
      search = {
        force = true;
        default = "kagi";
        privateDefault = "kagi";
        order = ["kagi"];
        engines = {
          kagi = {
            name = "Kagi";
            urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
            icon = "https://kagi.com/favicon.ico";
          };
          github = {
            name = "GitHub";
            urls = [{template = "https://github.com/search?q={searchTerms}&type=repositories";}];
            icon = "https://github.com/favicon.ico";
            definedAliases = ["@gh"];
          };
          flathub = {
            name = "Flathub";
            urls = [{template = "https://flathub.org/en/apps/search?q={searchTerms}";}];
            icon = "https://dl.flathub.org/assets/_next/public/favicon.svg";
            definedAliases = ["@fh"];
          };
          kubesearch = {
            name = "Kubesearch";
            urls = [{template = "https://kubesearch.dev/#{searchTerms}";}];
            definedAliases = ["@ku"];
          };
          nixpkgs = {
            name = "Nix Packages";
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            icon = "https://nixos.org/favicon.ico";
            definedAliases = ["@nx"];
          };
          nixoptions = {
            name = "Nix Options";
            urls = [{template = "https://search.nixos.org/options?channel=26.05&query={searchTerms}";}];
            icon = "https://nixos.org/favicon.ico";
            definedAliases = ["@no"];
          };
          opensecrets = {
            name = "Open Secrets";
            urls = [{template = "https://www.opensecrets.org/search?q={searchTerms}";}];
            definedAliases = ["@os"];
          };
          protondb = {
            name = "ProtonDB";
            urls = [{template = "https://www.protondb.com/search?q={searchTerms}";}];
            definedAliases = ["@pr"];
          };
          bing.metaData.hidden = true;
        };
      };
      #bookmarks = {};
      #extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
      #  bitwarden
      #  ublock-origin
      #  reddit-enhancement-suite
      #  #sponsorblock
      #  #youtube-shorts-block
      #];
      settings = {
        
        # Required for sidebery customization
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # General settings
        "browser.startup.homepage" = "bookmarks.labs.lianas.org";
        "browser.aboutConfig.showWarning" = false;

        # Disable firefox init
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.feeds.showFirstRunUI" = false;
        "browser.messaging-system.whatsNewPanel.enabled" = false;
        "browser.rights.3.shown" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.uitour.enabled" = false;
        "startup.homepage_override_url" = "";
        "trailhead.firstrun.didSeeAboutWelcome" = true;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.bookmarks.addedImportButton" = true;

        "browser.download.useDownloadDir" = false;

        # Disable home activity stream page
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.showWeather" = false;

        # Disable telemetry
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.all" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.sessions.current.clean" = true;
        "devtools.onboarding.telemetry.logged" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "toolkit.telemetry.hybridContent.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.prompted" = 2;
        "toolkit.telemetry.rejected" = true;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.unifiedIsOptIn" = false;
        "toolkit.telemetry.updatePing.enabled" = false;

        # Disable fx accounts
        "identity.fxaccounts.enabled" = false;

        # Harden
        "privacy.trackingprotection.enabled" = true;
        "dom.security.https_only_mode" = true;
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;
        "signon.management.page.breach-alerts.enabled" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "extensions.formautofill.available" = "off";

        # Remove close button
        "browser.tabs.inTitlebar" = 0;

        # Smooth scrolling
        "general.smoothScroll" = true;
        "general.smoothScroll.msdPhysics.enabled" = true;
        "mousewheel.min_line_scroll_amount" = 30;

        # Enable GPU acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "widget.dmabuf.force-enabled" = true;

        # Reduce iGPU usage
        "ui.prefersReducedMotion" = 1;

        # Max framerate
        "layout.frame_rate" = 120;

        # default 0.002
        "apz.fling_friction" = "0.003";

        # default 0.5
        "apz.fling_min_velocity_threshold" = "1.0";

        # Vertical tabs
        "sidebar.verticalTabs" = true;
        "sidebar.revamp" = true;
        "sidebar.main.tools" = ["history" "bookmarks"];

        # Wayland popup/menu fixes
        "widget.wayland.use-move-to-rect" = false;
        "widget.gtk.ignore-bogus-leave-notify" = 1;
        "widget.use-xdg-desktop-portal.file-picker" = 0;
        "widget.use-xdg-desktop-portal.mime-handler" = 0;
        "widget.non-native-theme.enabled" = false;
      };
      #restrictedDomainsList = [
      #  "accounts-static.cdn.mozilla.net"
      #  "accounts.firefox.com"
      #  "addons.cdn.mozilla.net"
      #  "addons.mozilla.org"
      #  "api.accounts.firefox.com"
      #  "beta.foldingathome.org"
      #  "cloud.tenjin-dk.com"
      #  "content.cdn.mozilla.net"
      #  "discovery.addons.mozilla.org"
      #  "install.mozilla.org"
      #  "media.tenjin-dk.com"
      #  "media.tenjin.com"
      #  "metrics.tenjin-dk.com"
      #  "metrics.tenjin.com"
      #  "oauth.accounts.firefox.com"
      #  "private.tenjin.com"
      #  "profile.accounts.firefox.com"
      #  "public.tenjin.com"
      #  "support.mozilla.org"
      #  "sync.services.mozilla.com"
      #];

    # Sidebery customization
    userChrome = ''
      :root {
        --toolbar-bgcolor: ${colors.darker} !important;
        --lwt-accent-color: ${colors.darker} !important;
        --newtab-background-color: ${colors.darker} !important;
        --sidebar-background-color: ${colors.darker} !important;
      }

      /**
      * Hide sidebar-panel-header (sidebar.revamp: true)
      */

      #sidebar-main,
      #sidebar-launcher-splitter {
        display: none !important;
      }

      /* Hide sidebar-panel-header (sidebar.revamp: true) */
      #sidebar-panel-header {
        display: none;
      }

      /* Sidebery styles applied globally (title preface gate removed) */
      #TabsToolbar > * { display: none !important; }
      #nav-bar { border-color: transparent !important; }

      #sidebar-box { padding: 0 !important; }
      #sidebar-box #sidebar {
        box-shadow: none !important;
        border: none !important;
        outline: none !important;
        border-radius: 0 !important;
      }
      #sidebar-splitter {
        --splitter-width: 3px !important;
        min-width: var(--splitter-width) !important;
        width: var(--splitter-width) !important;
        padding: 0 !important;
        margin: 0 calc(-1*var(--splitter-width) + 1px) 0 0 !important;
        border: 0 !important;
        opacity: 0 !important;
      }
      #sidebar-header { display: none !important; }

      .urlbarView-row[selected],
      .urlbarView-row[selected] .urlbarView-title,
      .urlbarView-row[selected] .urlbarView-url,
      .urlbarView-row[selected] .urlbarView-title-separator,
      .urlbarView-row[selected] .urlbarView-action,
      .urlbarView-row[selected] .urlbarView-secondary-action {
        background-color: ${indigo} !important;
        color: ${white} !important;
      }

      #urlbar-input::selection,
      #urlbar .urlbar-input-box ::selection {
        background-color: ${indigo} !important;
        color: ${white} !important;
      }
    '';
    };
  };

  #home = {
  #  persistence = {
  #    # Comment to disable persistence
  #    "/persist".directories = [ ".mozilla/firefox" ];
  #  };
  #};

  xdg.configFile."xfce4/helpers.rc".text = ''
    WebBrowser=firefox
  '';
}
