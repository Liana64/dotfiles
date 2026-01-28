{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    # TODO: Add gpg key
    settings = {
      user.name = "Liana";
      user.email = "mail@lianas.org";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}
