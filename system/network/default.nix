{config, lib, pkgs, ...}:
{
  imports = [
    ./wireless.nix
    ./wireguard.nix
  ];
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  #services.printing.enable = true;
  #services.avahi = {
  #  enable = true;
  #  nssmdns4 = true;
  #  openFirewall = true;
  #};
}
