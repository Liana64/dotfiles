# @desc: microVM guest base (not imported; consumed by modules/virt/*-vm.nix)
{inputs}: {lib, ...}: {
  imports = [inputs.microvm.nixosModules.microvm];

  environment.defaultPackages = lib.mkForce [];
  documentation.enable = false;
  documentation.man.enable = false;

  system.stateVersion = "26.05";
}
