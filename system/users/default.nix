{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./email.nix
  ];

  environment.variables.TERM = "xterm-256color";
  environment.variables.EDITOR = "vim";
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
  programs.zsh.enable = true;
}
