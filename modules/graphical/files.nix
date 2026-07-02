# @desc: Thunar file manager
{...}: {
  flake.modules.nixos.files = {...}: {
    programs.thunar.enable = true;
  };
}
