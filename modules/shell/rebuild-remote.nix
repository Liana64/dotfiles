# @desc: rebuild-remote — nixos-rebuild switch built and activated on the target host
{...}: {
  flake.modules.homeManager.rebuild-remote = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "rebuild-remote" (builtins.readFile ../bin/rebuild-remote))
    ];
  };
}
