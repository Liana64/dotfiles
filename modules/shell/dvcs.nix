# @desc: DVCS config; hardcodes user liana / email
{...}: let
  user = {
    name = "Liana";
    email = "liana@lianas.org";
  };
  signingKey = "C4E1D3BB2F69070998CE1981DC03DFEB7A0A710D";
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
