{config, lib, pkgs, ...}:
{
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  
  # Allow localsend
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };
}
