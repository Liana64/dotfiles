{ pkgs, ... }: {
  imports = [
    ../common
    ./aliases.nix
    ./element.nix
    ./firefox.nix
    ./framework.nix
    ./kdeconnect.nix
    ./gpg.nix
    ./mako.nix
    ./packages.nix
    ./rofi.nix
    ./sway.nix
    ./swaybg.nix
    ./waybar.nix
  ];
  
  #environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
