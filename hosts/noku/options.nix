# Draft TV host — do not deploy as-is:
#   - kdePackages is overlaid from nixpkgs-unstable (bigscreen needs Plasma >= 6.7,
#     stable 26.05 ships 6.6); drop the overlay in modules/graphical/bigscreen.nix
#     once stable carries it
#   - hardware-configuration.nix is a stub; regenerate on the box
#   - disko.nix has no disk device yet (CHANGEME); set it before installing
#   - every aspect still loads: framework laptop hw (nixos-hardware AMD AI 300,
#     fprintd, eDP video param), lanzaboote (enroll sbctl keys first),
#     usbguard (enroll the remote/dongle), sops (needs this host's age key)
#   - password is locked; set initialHashedPassword (mkpasswd -m yescrypt)
{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "noku";
  compositor = "bigscreen";
  theme = "milberry";

  users.users.liana.initialHashedPassword = "!";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
