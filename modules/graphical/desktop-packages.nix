# @desc: Linux-only graphical user packages
{...}: {
  flake.modules.homeManager.desktopPackages = {
    pkgs,
    # nixpkgs-unstable,
    ...
  }: {
    home.packages = with pkgs; [
      autotiling-rs
      bc
      cosign
      moreutils
      networkmanagerapplet
      pavucontrol
      pciutils
      protonmail-bridge
    ];
    # ++ (with nixpkgs-unstable; [
    # talhelper (home-infra devshell)
    # ]);
  };
}
