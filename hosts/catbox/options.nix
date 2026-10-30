# Ryzen 7 9800X3D, Radeon RX 7900 XT, Gigabyte B850 Gaming X WiFi6E
{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (inputs.self.network) cluster clients;
  set = lib.concatStringsSep ", ";
in {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.jovian.nixosModules.default
    ./disko.nix
    ./games.nix
    ./media.nix
    ./streaming.nix
  ];

  networking.hostName = "catbox";
  motd = {
    description = "living-room console and media client";
    commands = [
      ["sudo systemctl restart display-manager" "restart Steam session"]
      (with config.services.prometheus.exporters; [":${toString node.port} :${toString smartctl.port}" "node · smartctl exporters"])
    ];
  };
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader.systemd-boot = {
      enable = true;
      editor = false;
    };
    loader.efi.canTouchEfiVariables = true;
    initrd.systemd.enable = true;
    initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
    kernelModules = ["kvm-amd"];
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "home";
    };
    hardware.has.amd.gpu = true;
  };
  systemd.services.display-manager = {
    wants = ["network-online.target"];
    after = ["network-online.target"];
  };
  systemd.user.services.gamescope-session.serviceConfig.UnsetEnvironment = ["WAYLAND_DISPLAY" "DISPLAY"];
  networking.modemmanager.enable = false;
  services.orca.enable = false;

  users.users = {
    liana.openssh.authorizedKeys.keys = inputs.self.keys.liana;
    home = {
      isNormalUser = true;
      hashedPassword = "";
    };
  };

  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      AllowUsers = ["liana"];
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthOptions = "verify-required";
    };
  };
  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = ["systemd"];
    };
    smartctl.enable = true;
  };

  networking.firewall.extraInputRules = ''
    ip saddr { ${set clients.liana} } tcp dport 22 accept
    ip saddr { ${set cluster.nodes} } tcp dport { 9100, 9633 } accept
  '';

  zramSwap.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.11";
}
