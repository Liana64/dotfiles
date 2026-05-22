{ pkgs, ... }:
{
  # Theme (theme.name, window.opacity) is supplied by the stylix vicinae target.
  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;

    # Start after sway exports the session env so launched apps resolve.
    systemd = {
      enable = true;
      target = "sway-session.target";
    };

    settings = {
      faviconService = "twenty";
      font.size = 11;
      popToRootOnClose = true;
      rootSearch.searchFiles = false;
      window = {
        csd = true;
        rounding = 10;
      };
    };
  };
}
