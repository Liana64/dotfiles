{ pkgs, ... }: {
  security = {
    polkit.enable = true;
    rtkit.enable = true;
    #forcePageTableIsolation = true;
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true; # Monitor with journalctl -u apparmor
      packages = [pkgs.apparmor-profiles];
    };
  };
}
