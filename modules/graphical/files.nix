# @desc: Thunar file manager
{...}: {
  flake.modules.nixos.files = {pkgs, ...}: {
    programs.thunar.enable = true;
  };
}
