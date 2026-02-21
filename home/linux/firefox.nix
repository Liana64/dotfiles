{
  pkgs,
  inputs,
  ...
}: {
  programs.firefox = {
    enable = true;
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
            definedAliases = ["@g"];
          };
          kubesearch = {
            name = "Kubesearch";
            urls = [{template = "https://kubesearch.dev/#{searchTerms}";}];
            definedAliases = ["@k"];
          };
          nixpkgs = {
            name = "Nix Packages";
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            icon = "https://nixos.org/favicon.ico";
            definedAliases = ["@nx"];
          };
          searchix = {
            name = "Nix Options";
            urls = [{template = "https://searchix.ovh/?query={searchTerms}";}];
            icon = "https://searchix.ovh/favicon.ico";
            definedAliases = ["@no"];
          };
          opensecrets = {
            name = "Open Secrets";
            urls = [{template = "https://www.opensecrets.org/search?q={searchTerms}";}];
            definedAliases = ["@os"];
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
        "browser.startup.homepage" = "labs.lianas.org";
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

        # Remove close button
        "browser.tabs.inTitlebar" = 0;

        # Vertical tabs
        #"sidebar.verticalTabs" = true;
        #"sidebar.revamp" = true;
        #"sidebar.main.tools" = ["history" "bookmarks"];
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
      /**
      * Hide sidebar-panel-header (sidebar.revamp: true)
      */
      #sidebar-panel-header {
        display: none;
      }

      /**
      * Dynamic styles
      *
      * Choose when styles below will be activated (comment/uncomment line)
      * - When Sidebery set title preface "."
      * - When Sidebery sidebar is active
      */
      #main-window[titlepreface="."] {
      /* #main-window:has(#sidebar-box[sidebarcommand="_3c078156-979c-498b-8990-85f7987dd929_-sidebar-action"][checked="true"]) { */

        /* Hide horizontal native tabs toolbar */
        #TabsToolbar > * {
          display: none !important;
        }

        /* Hide top window border */
        #nav-bar {
          border-color: transparent !important;
        }

        /* Hide new Firefox sidebar, restyle addon's sidebar */
        #sidebar-main, #sidebar-launcher-splitter {
          display: none !important;
        }
        #sidebar-box {
          padding: 0 !important;
        }
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

        /* Update background color of the #browser area (it's visible near the
        rounded corner of the web page) so it blends with sidebery color with 
        vertical nav-bar. */
        /* #browser {
          background-color: var(--lwt-accent-color) !important;
          background-image: none !important;
        } */

        /* Hide sidebar header (sidebar.revamp: false) */
        #sidebar-header {
          display: none !important;
        }

        /* Uncomment the block below to show window buttons in Firefox nav-bar 
        (maybe, I didn't test it on non-linux-tiled-wm env) */
        /* #nav-bar > .titlebar-buttonbox-container,
        #nav-bar > .titlebar-buttonbox-container > .titlebar-buttonbox {
          display: flex !important;
        } */

        /* Uncomment one of the lines below if you need space near window buttons */
        /* #nav-bar > .titlebar-spacer[type="pre-tabs"] { display: flex !important; } */
        /* #nav-bar > .titlebar-spacer[type="post-tabs"] { display: flex !important; } */
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

  # Set firefox as default browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
    };
  };
}
