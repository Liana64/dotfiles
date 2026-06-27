# @desc: Vicinae launcher
{ pkgs, ... }:
{
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
}
