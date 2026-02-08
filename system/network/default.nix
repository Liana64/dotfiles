{config, lib, pkgs, ...}:
{
  imports = [
    ./wireless.nix
    ./wireguard.nix
  ];
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;
  
  # Allow localsend
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 8080 8443 3478 10001];
    allowedUDPPorts = [ 53317 8080 8443 3478 10001];
  };
  
  environment.systemPackages = with pkgs; [
    traceroute
  ];

  # Allow printing
  #services.printing.enable = true;
  #services.avahi = {
  #  enable = true;
  #  nssmdns4 = true;
  #  openFirewall = true;
  #};
}
