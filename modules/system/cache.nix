# @desc: Wipe XDG cache every 30 days
{...}: {
  flake.modules.homeManager.cache = {
    xdg.configFile."user-tmpfiles.d/cache.conf".text = ''
      R! %h/.cache/mozilla - - - -
      e %h/.cache - - - 30d
    '';
  };
}
