# @desc: Wipe XDG cache every 30 days
_: {
  flake.modules.homeManager.cache = {
    xdg.configFile."user-tmpfiles.d/cache.conf".text = ''
      R! %h/.cache/mozilla - - - -
      x %h/.cache/pre-commit - - - -
      e %h/.cache - - - 30d
    '';
  };
}
