# @desc: Vicinae launcher
{...}: {
  flake.modules.homeManager.vicinae = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # Qt exercises @resources at will (affinity, priority, scheduler — an
    # enumerated exception crash-looped), the node extension manager JITs
    # (MDWE), and EGL needs /dev/dri; home read-only with state dirs carved out
    systemd.user.services.vicinae.Service =
      hardening.confined
      // {
        SystemCallFilter = ["@system-service" "~@privileged"];
        MemoryDenyWriteExecute = false;
        PrivateDevices = false;
        ProtectHome = "read-only";
        ReadWritePaths = "%t %h/.local/share/vicinae %h/.local/state/vicinae %h/.cache/vicinae";
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
        window = {
          csd = true;
          rounding = 10;
        };
      };
    };
  };
}
