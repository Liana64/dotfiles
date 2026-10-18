# @desc: fooyin music player
{...}: {
  flake.modules.homeManager.fooyin = {pkgs, ...}: {
    home.packages = [(pkgs.fooyin.override {libvgm = null;})]; # remove unfree
  };
}
