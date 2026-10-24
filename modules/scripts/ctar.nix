# @desc: ctar — signed+encrypted tar archives using YubiKey
{...}: {
  flake.modules.homeManager.ctar = {pkgs, ...}: {
    home.packages = [
      (import ../_lib/shell-app.nix pkgs "ctar" {
        runtimeInputs = with pkgs; [coreutils findutils gnugrep gnupg gnutar gzip zstd];
      })
    ];
  };
}
