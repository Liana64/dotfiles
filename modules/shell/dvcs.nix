# @desc: DVCS config; hardcodes user liana / email
{...}: let
  user = {
    name = "Liana";
    email = "liana@lianas.org";
  };
in {
  flake.modules.homeManager.dvcs = {pkgs, ...}: {
    programs.git = {
      enable = true;

      # TODO: Add gpg key
      settings = {
        inherit user;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        inherit user;
        ui.diff-formatter = ["difft" "--color=always" "$left" "$right"];
      };
    };

    programs.gh.enable = true;

    home.packages = [pkgs.jjui];
  };
}
