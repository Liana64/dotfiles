# @desc: Curated fortune file + dice wrapper
{...}: {
  flake.modules.homeManager.dice = {
    inputs,
    pkgs,
    ...
  }: {
    home.packages = [inputs.dice.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
