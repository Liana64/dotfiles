# TODO: Organize this nightmare of files and get things out of nixos config that belong here
{ inputs, lib, config, pkgs, colors, ... }: {
#let
#  colors = import ../common/colors/gruvbox.nix { };
#in {
  home.username = "liana";
  home.homeDirectory = "/home/liana";

  imports = [
    ../../home/linux
  ];

  home.file.".wallpapers" = {
    source = ../../wallpapers;
    recursive = true;
  };

  home.sessionVariables = {
    NIX_CONFIG = "experimental-features = nix-command flakes";
  };

  programs.home-manager.enable = true;
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };
  };
}
