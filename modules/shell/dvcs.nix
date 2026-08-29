# @desc: DVCS config; hardcodes user liana / email
{...}: let
  user = {
    name = "Liana";
    email = "liana@lianas.org";
  };
  signingKey = "2348524E0BC72DAD1638EC79EEE4B7E49941B009";
in {
  flake.modules.homeManager.dvcs = {pkgs, ...}: {
    programs.git = {
      enable = true;

      settings = {
        user = user // {signingkey = signingKey;};
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        commit.gpgsign = true;
        tag.gpgsign = true;
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        inherit user;
        signing = {
          behavior = "own";
          backend = "gpg";
          key = signingKey;
        };
        ui.diff-formatter = ["difft" "--color=always" "$left" "$right"];
      };
    };

    programs.gh.enable = true;

    home.packages = [pkgs.jjui];
  };
}
