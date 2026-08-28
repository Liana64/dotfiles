{
  config,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "portable";
  theme = "milberry";

  sops.defaultSopsFile = lib.mkForce (inputs.secrets + "/framework.yaml");

  sops.secrets."users/liana/password".neededForUsers = true;
  users.mutableUsers = false;
  users.users.liana.hashedPasswordFile = config.sops.secrets."users/liana/password".path;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";
}
