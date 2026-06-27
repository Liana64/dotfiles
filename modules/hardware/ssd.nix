# @desc: SSD tuning (fstrim)
{...}: {
  flake.modules.nixos.ssd = {lib, ...}: {
    services.fstrim.enable = lib.mkDefault true;
    services.smartd.enable = true;
  };
}
