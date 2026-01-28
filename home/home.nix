# This file replaces ~/.config/nixpkgs/home.nix
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    ./shell
    ./dev
    ./emacs
    ./services
    ./web
  ];

  nixpkgs = {
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "liana";
    homeDirectory = "/home/liana";
  };

  home.sessionVariables = {
    NIX_CONFIG = "experimental-features = nix-command flakes";
  };

  home.packages = with pkgs; [
    firefox
    libreoffice
    element-desktop
    bitwarden-cli
    vlc
    vesktop
    ffmpeg
    thunderbird
    halloy
    moonlight-qt
    yazi
    chromium
    pavucontrol

    # Paid
    obsidian # TODO: Move to freeware
    protonmail-bridge
    protonmail-desktop
    cider-2
  ];

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
      size = 24;
    };
  };

  xdg.configFile."sway/config".source = ./sway/config;

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
