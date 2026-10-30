{
  inputs,
  lib,
  ...
}: let
  inherit (inputs.self.network) home clients;
  set = lib.concatStringsSep ", ";
  peers = set ([home.subnet] ++ clients.liana);
in {
  hardware.display = {
    edid.modelines."dummy1080" = "148.50 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync";
    outputs."HDMI-A-1" = {
      edid = "dummy1080.bin";
      mode = "e";
    };
  };

  nixpkgs.overlays = [
    (_: prev: {
      jovianPackages = prev.jovianPackages.overrideScope (_: p: {
        gamescope-session = p.gamescope-session.overrideAttrs (o: {
          postPatch =
            o.postPatch
            + ''
              substituteInPlace gamescope-session --replace-fail "-O '*',eDP-1" "-O DP-3,HDMI-A-1"
            '';
        });
      });
    })
  ];

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
  };

  networking.interfaces.enp10s0.wakeOnLan.enable = true;

  networking.firewall.extraInputRules = ''
    ip saddr { ${peers} } tcp dport { 47984, 47989, 48010 } accept
    ip saddr { ${peers} } udp dport { 47998-48000, 48002, 48010 } accept
    ip saddr { ${set clients.liana} } tcp dport 47990 accept
  '';
}
