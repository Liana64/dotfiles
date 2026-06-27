# @desc: Curated fortune file + dice wrapper
{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.dice.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
