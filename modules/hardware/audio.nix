{
  config,
  ...
}: {

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    # Auto-switch the default sink to newly-connected devices (e.g. bluetooth
    # headphones). When the device disappears, wireplumber falls back to the
    # next-highest-priority sink (the dock, if present).
    wireplumber.extraConfig."51-default-sink-auto-switch" = {
      "wireplumber.settings" = {
        "default-nodes.auto-switch" = true;
      };
    };
  };
}
