{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "Liana";
    userEmail = "mail@lianas.org";
    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };
}
