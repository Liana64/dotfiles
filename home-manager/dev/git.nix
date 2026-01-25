{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      user.name = "Liana";
      user.email = "mail@lianas.org";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
