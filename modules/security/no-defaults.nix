# @desc: Strip default packages
{...}: {
  flake.modules.nixos.noDefaults = {lib, ...}: {
    environment.defaultPackages = lib.mkForce [];
  };
}
