# @desc: Vicinae launcher
{...}: {
  flake.modules.homeManager.vicinae = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # qt needs @resources, mesa needs mincore (SIGSYS on first render),
    # node extension manager JITs (MDWE), EGL needs /dev/dri,
    # home read-only with vicinae state dirs carved out
    systemd.user.services.vicinae.Service =
      hardening.confined
      // {
        SystemCallFilter = ["@system-service" "~@privileged" "mincore"];
        MemoryDenyWriteExecute = false;
        PrivateDevices = false;
        ProtectHome = "read-only";
        ReadWritePaths = "%t %h/.local/share/vicinae %h/.local/state/vicinae %h/.cache/vicinae";
        # indexer logs every scan at hardcoded debug, no level knob exists (0.22.3)
        LogRateLimitIntervalSec = "10min";
        LogRateLimitBurst = 50;
      };

    programs.vicinae = {
      enable = true;
      package = pkgs.vicinae;

      systemd = {
        enable = true;
        target = "graphical-session.target";
      };

      settings = {
        faviconService = "twenty";
        font.size = 11;
        popToRootOnClose = true;
        rootSearch.searchFiles = false;
        providers.clipboard.preferences.monitoring = false;
        # launched apps otherwise inherit the unit sandbox and die on first
        # home write, the user manager spawns them outside it
        providers.applications.preferences.launchPrefix = "systemd-run --user --collect --";
        window = {
          csd = true;
          rounding = 10;
        };
      };
    };
  };
}
