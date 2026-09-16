# @desc: Anki spaced repetition
{...}: {
  flake.modules.homeManager.anki = {...}: {
    programs.anki = {
      enable = true;
    };
  };
}
