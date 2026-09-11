# bootloader is unsigned, sign with the sbctl keys before first secure boot
{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    inputs.jovian.nixosModules.default
    ./disko.nix
    ./impermanence.nix
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;

  system.nixos.distroName = "deck";
  networking.hostName = "deck";
  networking.networkmanager.enable = true;

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.editor = false;
    loader.efi.canTouchEfiVariables = true;
    initrd.systemd.enable = true;
    initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid"];
    kernelModules = ["kvm-amd"];
  };

  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = "liana";
      desktopSession = "gamescope-wayland";
    };
    hardware.has.amd.gpu = true;
  };

  users.users.liana.initialHashedPassword = "!";
  zramSwap.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
