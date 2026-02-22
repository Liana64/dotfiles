{config, lib, pkgs, ...}:
{
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  
  networking.firewall = {
    enable = true;
    
    # Allow localsend
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];

    # Allow kdeconnect
    #allowedTCPPortRanges = [
    #  {
    #    from = 1714;
    #    to = 1764;
    #  }
    #];
    #allowedUDPPortRanges = [
    #  {
    #    from = 1714;
    #    to = 1764;
    #  }
    #];
  };
}
