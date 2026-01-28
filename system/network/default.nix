{config, pkgs, ...}:
{
  imports = [
    ./wireless.nix
    ./wireguard.nix
  ];
  networking.hostName = "framework";
  networking.networkmanager.enable = true;
}
