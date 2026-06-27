# @desc: Code formatter (alejandra)
{...}: {
  perSystem = {pkgs, ...}: {
    formatter = pkgs.alejandra;
  };
}
