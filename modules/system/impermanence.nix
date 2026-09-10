# @desc: impermanence option — ephemeral-root switch consumed by other aspects
{...}: {
  flake.modules.nixos.impermanence = {lib, ...}: {
    options.impermanence = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Ephemeral root: @root is rolled back to @root-blank each boot";
    };
  };
}
