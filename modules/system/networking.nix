# @desc: NetworkManager + nftables firewall
{...}: {
  flake.modules.nixos.networking = {lib, ...}: {
    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkDefault true;

    # iptables is pretty old by now
    networking.nftables.enable = true;

    networking.firewall = {
      enable = true;
      logRefusedConnections = true;

      # Allow localsend
      allowedTCPPorts = [53317];
      allowedUDPPorts = [53317];

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
  };
}
