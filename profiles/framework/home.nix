# TODO: Organize this nightmare of files and get things out of nixos config that belong here
{ inputs, lib, config, pkgs, colors, ... }: {
#let
#  colors = import ../common/colors/gruvbox.nix { };
#in {
  home.username = "liana";
  home.homeDirectory = "/home/liana";

  imports = [
    ../../home/shell
    ../../home/graphical
    ../../home/dev
    ../../home/services
    ../../home/web
  ];

  nixpkgs = {
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home.file.".wallpapers" = {
    source = ../../wallpapers;
    recursive = true;
  };

  home.sessionVariables = {
    NIX_CONFIG = "experimental-features = nix-command flakes";
  };

  home.packages = with pkgs; [
    firefox
    libreoffice
    bitwarden-cli
    vlc
    vesktop
    ffmpeg
    thunderbird
    halloy
    moonlight-qt
    yazi
    ungoogled-chromium
    pavucontrol
    pciutils
    usbutils
    moreutils
    bitwarden-desktop
    #trash-cli
    fzf
    xdg-desktop-portal
    bc

    # Paid
    obsidian
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
    };
  };

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
