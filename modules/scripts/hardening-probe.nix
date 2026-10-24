# @desc: hardening-probe — run a command or live unit under a systemd-hardening preset
{...}: {
  flake.modules.homeManager.hardening-probe = {
    lib,
    pkgs,
    hardening,
    ...
  }: let
    toProps = preset: lib.concatStringsSep "\n" (hardening.lines preset);
  in {
    home.packages = [
      (import ../_lib/shell-app.nix pkgs "hardening-probe" {
        runtimeInputs = with pkgs; [audit systemd coreutils gnused gnugrep jq];
        runtimeEnv = {
          HARDENING_BASE = toProps hardening.base;
          HARDENING_LAUNCH = toProps hardening.launch;
          HARDENING_CONFINED = toProps hardening.confined;
          HARDENING_AIRGAPPED = toProps hardening.airgapped;
        };
      })
    ];
  };
}
