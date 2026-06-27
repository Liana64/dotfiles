# @desc: SSD tuning (fstrim)
{ lib, ... }:
{
  services.fstrim.enable = lib.mkDefault true;
  services.smartd.enable = true;
}
