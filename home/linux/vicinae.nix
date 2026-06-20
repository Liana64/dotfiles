{ pkgs, ... }:
{
  # Theme (theme.name, window.opacity) is supplied by the stylix vicinae target.
  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;

    # Bind to graphical-session.target so the server starts under both sway and niri.
    systemd = {
      enable = true;
      target = "graphical-session.target";
    };

    settings = {
      faviconService = "twenty";
      font.size = 11;
      popToRootOnClose = true;
      rootSearch.searchFiles = false;
      # Disable clipboard history: stop the clipboard server recording selections.
      providers.clipboard.preferences.monitoring = false;
      window = {
        csd = true;
        rounding = 10;
      };
    };
  };
}
