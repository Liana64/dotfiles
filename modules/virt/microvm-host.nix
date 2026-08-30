# @desc: microvm.nix host runner
{inputs, ...}: {
  flake.modules.nixos.microvm-host = {
    imports = [inputs.microvm.nixosModules.host];
  };
}
