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
    ./git.nix
    ./aliases.nix
    ./shell.nix
    ./dev.nix
    ./emacs.nix
    ./firefox.nix
    ./syncthing.nix
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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

  home.packages = with pkgs; [
    firefox
    element-desktop
    bitwarden-cli
    vlc
    vesktop
    ffmpeg
    protonmail-bridge
    thunderbird
    htop
  ];

  programs.home-manager.enable = true;
  programs.niri.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
