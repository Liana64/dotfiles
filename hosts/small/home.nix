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
    ../home/shell
    ../home/dev
    #./services
    #./web
  ];

  nixpkgs = {
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "liana";
    homeDirectory = "/Users/liana";
  };

  home.packages = with pkgs; [
    ffmpeg
    thunderbird
    htop
    halloy
  ];

  programs.home-manager.enable = true;
  #programs.niri.enable = true;

  #services.gpg-agent = {
  #  enable = true;
  #  defaultCacheTtl = 1800;
  #  enableSshSupport = true;
  #};

  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
