# @desc: persist-diff — ephemeral-root files that would vanish on reboot
{...}: {
  flake.modules.homeManager.persist-diff = {pkgs, ...}: {
    home.packages = [
      (import ../_lib/shell-app.nix pkgs "persist-diff" {
        runtimeInputs = with pkgs; [btrfs-progs coreutils gnused util-linux];
      })
    ];
  };
}
