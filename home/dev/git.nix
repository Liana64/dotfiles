{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    # TODO: Add gpg key
    settings = {
      user.name = "Liana";
      user.email = "liana@lianas.org";
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.gh.enable = true;
}
