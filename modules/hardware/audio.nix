# @desc: Audio mixer fixes (ALC285 internal mic)
{...}: {
  flake.modules.nixos.audio = {
    config,
    pkgs,
    ...
  }: let
    # ALC285 internal mic distorts above ~50%: the stock ACP mixer path merges the
    # analog "Internal Mic Boost" amp into the capture slider, so high settings drive
    # that boost stage (noise/distortion). Drop the boost from the volume curve so the
    # slider maps onto the clean Capture amp only.
    acpPaths = pkgs.runCommand "acp-paths-no-mic-boost" {} ''
      cp -r ${pkgs.pipewire}/share/alsa-card-profile/mixer/paths $out
      chmod -R u+w $out
      ${pkgs.gnused}/bin/sed -i \
        -e '/^\[Element Internal Mic Boost\]/,/^\[/{ s/^volume = merge/volume = off/ }' \
        -e '/^\[Element Int Mic Boost\]/,/^\[/{ s/^volume = merge/volume = off/ }' \
        $out/analog-input-internal-mic.conf
    '';
  in {
    security.rtkit.enable = true;
    systemd.user.services.wireplumber.environment.ACP_PATHS_DIR = "${acpPaths}";
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;

      alsa.enable = true;

      # Auto-switch the default sink to newly-connected devices (e.g. bluetooth
      # headphones). When the device disappears, wireplumber falls back to the
      # next-highest-priority sink (the dock, if present).
      wireplumber.extraConfig."51-default-sink-auto-switch" = {
        "wireplumber.settings" = {
          "default-nodes.auto-switch" = true;
        };
      };
    };
  };
}
