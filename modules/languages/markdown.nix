# @desc: Markdown LSP for helix
{...}: {
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix.extraPackages = [pkgs.marksman];
  };
}
