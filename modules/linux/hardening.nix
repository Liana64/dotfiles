{ pkgs, ... }: {
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    #forcePageTableIsolation = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
      packages = [pkgs.apparmor-profiles];
    };
  };
}
