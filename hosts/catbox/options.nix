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
  ];

  networking.hostName = "catbox";
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
      desktopSession = "plasma";
    };
    hardware.has.amd.gpu = true;
  };
  services.desktopManager.plasma6.enable = true;

  machineSecrets = false;
  sops.secrets."users/liana/password".neededForUsers = true;
  users = {
    mutableUsers = false;
    users.liana = {
      hashedPasswordFile = config.sops.secrets."users/liana/password".path;
      openssh.authorizedKeys.keys = inputs.self.keys.liana;
    };
    users.home = {
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
