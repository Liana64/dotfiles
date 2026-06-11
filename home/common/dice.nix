{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.dice.packages.${pkgs.stdenv.hostPlatform.system}.default ];
}
