# @desc: transmit change sets between nix houses
{...}: {
  flake.modules.homeManager.veles = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "veles";
        runtimeInputs = with pkgs; [git gnutar coreutils findutils gnused];
        text = builtins.readFile ../bin/veles;
      })
    ];
  };
}
