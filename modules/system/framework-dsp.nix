# @desc: EasyEffects DSP for Framework 13 speakers, bound to sway
{...}: {
  flake.modules.homeManager.frameworkDsp = {
    inputs,
    lib,
    ...
  }: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # Improve the quality of the Framework 13 speakers with a DSP audio configuration
    services.easyeffects.enable = true;
    # data dir, not config: EE 7 reads presets from XDG data and treats the
    # config dir as a legacy source to migrate (which a store symlink can't be)
    xdg.dataFile."easyeffects/output/cab-fw.json".source = "${inputs.framework-dsp}/config/output/Gracefu's Edits.json";

    # Bind easyeffects to sway session
    systemd.user.services.easyeffects = {
      Unit = {
        PartOf = ["sway-session.target"];
        Requisite = ["sway-session.target"];
        After = ["sway-session.target"];
      };
      Install.WantedBy = lib.mkForce ["sway-session.target"];
      # Qt exercises @resources (SIGSYS on sched_setscheduler otherwise); the
      # single-instance socket lives under %t
      Service =
        hardening.confined
        // {
          SystemCallFilter = ["@system-service" "~@privileged"];
          ProtectHome = "read-only";
          ReadWritePaths = "%t %h/.local/share/easyeffects";
        };
    };

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";
  };
}
