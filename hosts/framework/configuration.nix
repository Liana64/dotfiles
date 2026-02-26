{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # inputs.self.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
    ../../modules/linux
    ../../modules/hardware
  ];

  networking.hostName = "framework";
  users.users = {
    liana = {
      shell = pkgs.zsh;
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!

      initialHashedPassword = "$7$GU..../....xWF998Wb.uTEdKMtYU8zN.$BiszmcjuUE1myXJw8no4IAMZof/gZ4kAObf3hDKhnY8";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];

      extraGroups = ["wheel" "networkmanager" "audio" "video" "dialout" "docker"];
    };
  };

  environment.variables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    TERM = "xterm-256color";
  };

  programs.zsh.enable = true;

  # Pinned NixOS version
  # See: https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  environment.systemPackages = with pkgs; [
    android-tools
    gimp
    gptfdisk
    localsend
    seahorse
    traceroute
    unzip
    vim
    wget
  ];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    #settings = {
    #  experimental-features = "nix-command flakes";
    #  # Opinionated: disable global registry
    #  flake-registry = "";
    #  # Workaround for https://github.com/NixOS/nix/issues/9574
    #  nix-path = config.nix.nixPath;
    #};
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

}
