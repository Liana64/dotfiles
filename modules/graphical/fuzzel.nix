# @desc: Fuzzel launcher
{...}: {
  flake.modules.homeManager.fuzzel = {
    lib,
    pkgs,
    ...
  }: {
    programs.fuzzel = {
      enable = true;
      package = pkgs.fuzzel;

      settings = {
        main = {
          font = lib.mkForce "Cantarell:size=14";
          terminal = "${pkgs.kitty}/bin/kitty -e";
          layer = "overlay";
          lines = 12;
          width = 40;
          horizontal-pad = 20;
          vertical-pad = 12;
          inner-pad = 6;
          exit-on-keyboard-focus-loss = true;
        };
        border = {
          width = 2;
          radius = 10;
        };
      };
    };
  };
}
