# @desc: sudo-rs in place of sudo
{...}: {
  flake.modules.nixos.sudo = {...}: {
    security.sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
  };
}
