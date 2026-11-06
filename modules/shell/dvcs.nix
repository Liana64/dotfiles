# @desc: DVCS config (git, jujutsu) signed as the primary user
{user, ...}: let
  identity = {
    inherit (user) email;
    name = user.fullName;
  };
in {
  flake.modules.homeManager.dvcs = {pkgs, ...}: {
    programs.git = {
      enable = true;

      settings = {
        user = identity // {signingkey = user.signingKey;};
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        commit.gpgsign = true;
        tag.gpgsign = true;
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user = identity;
        signing = {
          behavior = "own";
          backend = "gpg";
          key = user.signingKey;
        };
        ui.diff-formatter = ["difft" "--color=always" "$left" "$right"];
      };
    };

    programs.gh.enable = true;

    home.packages = [pkgs.jjui];
  };
}
