{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common
    ../../modules/linux
    ../../modules/hardware
  ];

  networking.hostName = "portable";
  theme = "milberry";

  users.users.liana.initialHashedPassword = "$y$j9T$kMLxfF6rfFExY7UuBim1Y/$r8B9xnm7bA7PEhvo6n7WXagnaV8BYr2hUkyuQhLWiFC";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
