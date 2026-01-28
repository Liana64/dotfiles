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
            definedAliases = ["@sx"];
          };
          opensecrets = {
            name = "Open Secrets";
            urls = [{template = "https://www.opensecrets.org/search?q={searchTerms}";}];
            definedAliases = ["@ot"];
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
        "browser.startup.homepage" = "labs.lianas.org";

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

        # Disable telemetry
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
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
    };
  };

  #home = {
  #  persistence = {
  #    # Comment to disable persistence
  #    "/persist".directories = [ ".mozilla/firefox" ];
  #  };
  #};

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
