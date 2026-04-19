{ pkgs, ... }: {
  imports = [
    ../common
    ./aliases.nix
    ./claude.nix
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
  
  #environment.variables.SHELL = "${pkgs.zsh}/bin/zsh";
  home.sessionVariables = {
    SHELL = "${pkgs.zsh}/bin/zsh";
  };

  home.sessionPath = [
    "$HOME/.local/share/devtools"
  ];

  #home.file.".local/share/flatpak/overrides/global".text = ''
  #  [Environment]
  #  ELECTRON_OZONE_PLATFORM_HINT=wayland
  #'';
}
