# @desc: EasyEffects DSP for Framework 13 speakers, bound to sway
{...}: {
  flake.modules.homeManager.frameworkDsp = {
    inputs,
    lib,
    ...
  }: {
    # Improve the quality of the Framework 13 speakers with a DSP audio configuration
    services.easyeffects.enable = true;
    xdg.configFile."easyeffects/output/cab-fw.json".source = "${inputs.framework-dsp}/config/output/Gracefu's Edits.json";

    # Bind easyeffects to sway session
    systemd.user.services.easyeffects = {
      Unit = {
        PartOf = ["sway-session.target"];
        Requisite = ["sway-session.target"];
        After = ["sway-session.target"];
      };
      Install.WantedBy = lib.mkForce ["sway-session.target"];
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";
  };
}
