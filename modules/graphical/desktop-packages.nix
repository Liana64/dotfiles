# @desc: Linux-only user packages (GUI + desktop)
{...}: {
  flake.modules.homeManager.desktopPackages = {
    pkgs,
    nixpkgs-unstable,
    ...
  }: {
    home.packages =
      (with pkgs; [
        autotiling-rs
        bc
        cosign
        cider-2
        moreutils
        networkmanagerapplet
        pavucontrol
        pciutils
        protonmail-bridge
      ])
      ++ (with nixpkgs-unstable; [
        talhelper
      ]);
  };
}
