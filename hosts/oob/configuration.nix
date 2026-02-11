# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  system.stateVersion = "23.05";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;

      # Disable for raspberry pi
      efi.canTouchEfiVariables = false;
    };

    kernelPackages = pkgs.linuxPackages_rpi4;

  #  lanzaboote = {
  #    enable = true;
  #    pkiBundle = "/var/lib/sbctl";
  #  };
  };

  environment.variables.EDITOR = "vim";
  users.users = {
    liana = {
      shell = pkgs.zsh;

      initialHashedPassword = "$7$GU..../....xWF998Wb.uTEdKMtYU8zN.$BiszmcjuUE1myXJw8no4IAMZof/gZ4kAObf3hDKhnY8";
      isNormalUser = true;
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCr5g6rtghAGWkO/fDfFDOS0QszZCkPrCoFo6hynf4n26sqdMyb14leWuRnYbro/HinDBUvv6AlsESc6NCfJmWuYP2fge3lhj+figX85uZX0ladFErHWKvR+M0ROUtBAXpcafDh2NYzoFYJyb6gwoCRRepduS6HGZN+XTbcMOSsqZXEdmHwArSkyJpRv1pN0YSKULkcOFjqneQ5+seVu0Xch6xAC9EPx33XcWcM2A7lyRVDd1cuahjEnW3YDY0MNgjxfqMcvV43C2k3MWIpmoQYx0Q1OlGo37iPtS+236qKjUN8+DgQSK54K4KTGULJyu9RyWzwDwHg5V7pUNjV8Yxoq/H3nA7C2aZyeJzEHz6SnrtDWdeeKYOYtD/c0v5vnSqwV87WjBCUJ7Q6Bz6MP6pjuYdrKKkKv9IVnG1kOkEaMDMJlIsTkFlAZKkMjn/TTd7NhuAHZhfc/pwMxiEcBOkuXxr4I1ENkZKRLcySq0LzB5MnzLlIoqP27tcYV7Hczbp3PDCpIshukf54QWK18tNiQRzKMnzy8daq0tE45wYZcOSSsceTbAdLceE8xhDBHkXymqHHFq2nDrVuOyIQLr6N2Qafwad7OHd2iF0PIsGXezZotORkQBZqY2XEp4CFueMH+4Fc9K4zot8CoHTaJux14AtBCmqMXUaO2poziAtXhw== liana@2024"];

      extraGroups = ["wheel" "networkmanager" "dialout" "docker"];
    };
  };
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    vim 
    git
    unzip
    wget
    docker
  ];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  #networking.firewall.enable = false;

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

}
