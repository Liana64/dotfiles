# @desc: WireGuard VPN
{...}: {
  flake.modules.nixos.wireguard = {
    pkgs,
    lib,
    ...
  }: let
    wireguardConfigFile = "/var/secrets/wireguard/wg0.conf";

    # openresolv first: systemd's resolvconf symlink resolves to resolvectl
    # otherwise, hijacking wg-quick's DNS setup and rolling the tunnel back.
    wgAutoconnect = pkgs.writeShellScript "wg-autoconnect" (''
        export PATH=${lib.makeBinPath [
          pkgs.openresolv
          pkgs.networkmanager
          pkgs.iproute2
          pkgs.wireguard-tools
          pkgs.findutils
          pkgs.gnugrep
          pkgs.coreutils
        ]}:$PATH
        export WG_CONFIG="${wireguardConfigFile}"
      ''
      + builtins.readFile ../../modules/bin/wireguard-autoconnect);
  in {
    # After spending a lot of time troubleshooting issues with wireguard that only seemed
    # to affect the linux clients, it turns out that you need to reload the wireguard server
    # service whenever you add a new peer. I hope that this comment helps someone, somewhere,
    # so that you don't have to go through what I did to figure this out. It hurt.

    networking.wg-quick.interfaces.wg0 = {
      configFile = wireguardConfigFile;
      listenPort = 51824;
      autostart = false;
    };

    # Connect to our VPN whenever we are on a network that isn't trusted. This isn't
    # entirely foolproof because someone could still spoof an SSID and BSSID, but it's
    # good enough for *me*. The trusted SSID list is hardcoded in the script body.
    #
    # Runs as a long-lived service driven by `nmcli monitor` rather than a
    # NetworkManager dispatcher script, so the same body works under SELinux on
    # Fedora, where the dispatcher domain is confined and blocks ip/wg-quick.
    systemd.services.wg-autoconnect = {
      description = "Auto-toggle WireGuard by network trust";
      after = ["NetworkManager.service"];
      wants = ["NetworkManager.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = wgAutoconnect;
        Restart = "always";
        RestartSec = 2;
      };
    };

    networking.networkmanager.unmanaged = ["interface-name:wg0"];

    # Manual VPN toggle for waybar — wg-quick directly so it mirrors the dispatcher.
    systemd.services.vpn-toggle = {
      description = "Toggle the WireGuard tunnel";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "vpn-toggle" ''
          export PATH=${pkgs.openresolv}/bin:$PATH
          if ${pkgs.iproute2}/bin/ip link show wg0 &>/dev/null; then
            ${pkgs.wireguard-tools}/bin/wg-quick down "${wireguardConfigFile}"
          else
            ${pkgs.wireguard-tools}/bin/wg-quick up "${wireguardConfigFile}"
          fi
        '';
      };
    };

    # Let a wheel user (waybar) start vpn-toggle without authenticating.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "vpn-toggle.service" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
