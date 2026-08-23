# @desc: NetworkManager + nftables firewall
{...}: {
  flake.modules.nixos.networking = {lib, ...}: {
    networking.networkmanager.enable = true;
    networking.useDHCP = lib.mkDefault true;

    # Per-network MAC keyed on SSID, not profile UUID ("stable"), so re-adding a
    # network keeps its address. Needs /var/lib/NetworkManager/secret_key persisted.
    # Override per network with:
    #   nmcli connection modify <name> 802-11-wireless.cloned-mac-address permanent
    # DHCP hostname still sent: no avahi/resolved here, so it is the only LAN
    # name path — discoverability over dropping a cross-network identifier.
    networking.networkmanager.wifi.macAddress = "stable-ssid";

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
