# @desc: Remmina remote desktop client
{...}: {
  flake.modules.homeManager.remmina = {pkgs, ...}: {
    home.packages = [
      ((pkgs.remmina.override {
          withLibsecret = false;
          withVte = false;
        }).overrideAttrs (o: {
          cmakeFlags = o.cmakeFlags ++ ["-DWITH_NEWS=OFF" "-DWITH_STATS=OFF" "-DWITH_TIP=OFF"];
        }))
    ];

    xdg.configFile."remmina/remmina.pref" = {
      force = true;
      text = ''
        [remmina_pref]
        trust_all=false
        deny_screenshot_clipboard=true
        disable_tray_icon=true
      '';
    };
  };
}
