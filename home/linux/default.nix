{ pkgs, ... }: {
  imports = [
    ../common
    ./aliases.nix
    ./dconf.nix
    ./element.nix
    ./firefox.nix
    ./framework.nix
    ./gpg.nix
    ./mako.nix
    ./packages.nix
    ./rofi.nix
    ./sway.nix
    ./swaybg.nix
    ./syncthing.nix
    ./waybar.nix
  ];
  
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
