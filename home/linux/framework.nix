{ inputs, ... }: {
  # Improve the quality of the Framework 13 speakers with a DSP audio configuration
  services.easyeffects.enable = true;
  xdg.configFile."easyeffects/output/cab-fw.json".source =
    "${inputs.framework-dsp}/config/output/Gracefu's Edits.json";

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
