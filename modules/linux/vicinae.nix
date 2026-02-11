{ inputs, pkgs, ... }:
{
  programs.vicinae = {
    enable = true;
    package = pkgs.vicinae;
    systemd.enable = true;
    settings = {
      theme.name = "vicinae-dark";
      faviconService = "twenty";
      font.size = 11;
      popToRootOnClose = true;
      rootSearch.searchFiles = false;
      window = {
        csd = true;
        opacity = 0.95;
        rounding = 10;
      };
    };
    extensions = [ ];
  };
}
