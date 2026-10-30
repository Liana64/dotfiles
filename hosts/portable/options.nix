{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "portable";
  theme = "milberry";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
