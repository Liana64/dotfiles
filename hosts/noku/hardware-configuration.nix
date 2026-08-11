# Stub — replace on the target:
#   nixos-generate-config --show-hardware-config
# (filesystems come from disko.nix; keep them out of the regenerated file)
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
