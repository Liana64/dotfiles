# @desc: Remmina remote desktop client
{...}: {
  flake.modules.homeManager.remmina = {pkgs, ...}: {
    home.packages = [
      ((pkgs.remmina.override {
          withKf5Wallet = false;
          withLibsecret = false;
          withVte = false;
        }).overrideAttrs (o: {
          cmakeFlags = o.cmakeFlags ++ ["-DWITH_NEWS=OFF" "-DWITH_STATS=OFF" "-DWITH_TIP=OFF"];
        }))
    ];

    xdg.configFile."remmina/plugins".source = pkgs.emptyDirectory;
    xdg.configFile."remmina/remmina.pref" = {
      force = true;
      text = ''
        [remmina_pref]
        deny_screenshot_clipboard=true
        disable_tray_icon=true

        [remmina]
        name=
        disableclipboard=1
        disablepasswordstoring=1
      '';
    };
  };
}
