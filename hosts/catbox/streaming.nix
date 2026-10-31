{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs.self.network) home clients;
  set = lib.concatStringsSep ", ";
  peers = set ([home.subnet] ++ clients.liana);
in {
  # TCL 65S555 is HDMI 2.0 (600 MHz TMDS)
  # -------------------------------------
  # 4K60 fits 8-bit RGB only
  # 4K60 HDR is dithered 8-bit
  # 120 Hz is 1440p/1080p only
  # -------------------------------------
  hardware.display = {
    edid.packages = [
      (pkgs.runCommand "edid-tcl-65s555" {} "install -Dm444 ${./data/tcl-65s555.bin} $out/lib/firmware/edid/tcl-65s555.bin")
    ];
    outputs."HDMI-A-1" = {
      edid = "tcl-65s555.bin";
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
