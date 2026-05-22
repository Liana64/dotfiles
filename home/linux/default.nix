{ pkgs, ... }: {
  imports = [
    ../common
    ./aliases.nix
    ./agentic.nix
    ./dconf.nix
    ./element.nix
    ./firefox.nix
    ./framework.nix
    ./gpg.nix
    ./mako.nix
    ./mime.nix
    ./obsidian.nix
    ./packages.nix
    ./rofi.nix
    ./sway.nix
    ./swaybg.nix
    ./syncthing.nix
    ./stylix.nix
    ./waybar.nix
    ./xdg-userdirs.nix
  ];
  
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };
}
