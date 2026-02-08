# TODO: Organize this nightmare of files and get things out of nixos config that belong here
{ inputs, lib, config, pkgs, colors, ... }: {
#let
#  colors = import ../common/colors/gruvbox.nix { };
#in {
  home.username = "liana";
  home.homeDirectory = "/home/liana";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home.sessionVariables = {
    NIX_CONFIG = "experimental-features = nix-command flakes";
  };

  home.packages = with pkgs; [
    docker
  ];

  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
