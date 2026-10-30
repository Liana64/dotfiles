{
  inputs,
  lib,
  pkgs,
  ...
}: let
  tv = pkgs.writeShellScriptBin "tv" ''
    exec ${pkgs.curl}/bin/curl -fsS -m 5 --retry 15 --retry-delay 1 --retry-all-errors -X POST "http://${inputs.self.network.home.hosts.tv}:8060/$1"
  '';
  tile = name: exec:
    pkgs.makeDesktopItem {
      inherit name exec;
      desktopName = name;
      icon = "applications-multimedia";
    };
  webapp = name: url: tile name "plasma-bigscreen-webapp --name ${name} ${url}";
in {
  jovian.steam.desktopSession = "plasma-bigscreen-wayland";
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sessionPackages = [pkgs.kdePackages.plasma-bigscreen];
  programs.kde-pim.enable = false;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [ark discover dolphin dolphin-plugins elisa gwenview kate khelpcenter konsole okular qrca spectacle];
  environment.etc."xdg/applications-blacklistrc".text = lib.generators.toINI {} {
    # plasma-bigscreen will overwrite this blacklist unless we make it immutable
    Applications."blacklist[$i]" = lib.concatStringsSep "," [
      "com.vysp3r.ProtonPlus"
      "cups"
      "dev.lizardbyte.app.Sunshine"
      "kdesystemsettings"
      "LocalSend"
      "net.retrodeck.retrodeck.Configurator"
      "nixos-manual"
      "org.kde.drkonqi.coredump.gui"
      "org.kde.kdeconnect.app"
      "org.kde.kdeconnect.nonplasma"
      "org.kde.kdeconnect.sms"
      "org.kde.kinfocenter"
      "org.kde.kmenuedit"
      "org.kde.kwalletmanager"
      "org.kde.plasma.bigscreen.inputhandler"
      "org.kde.plasma-systemmonitor"
      "org.kde.plasma.bigscreen.uvcviewer"
      "org.kde.plasma.emojier"
      "plasma-bigscreen-swap-session"
      "protontricks"
      "steam"
      "systemsettings"
    ];
  };
  environment.etc."xdg/kwinrc".text = lib.generators.toINI {} {
    Wayland."InputMethod[$i]" = "/run/current-system/sw/share/applications/org.kde.plasma.keyboard.desktop";
  };
  systemd.user.services.gamescope-session.serviceConfig.ExecStartPre = "-${pkgs.systemd}/bin/systemctl --user stop app-org.kde.plasma.bigscreen.inputhandler@*.service";
  systemd.tmpfiles.rules = ["D /home/home/.local/share/applications 0555 home users -"];

  systemd.services.tv-input = {
    description = "Wake the TV and switch it to catbox";
    wantedBy = ["multi-user.target"];
    wants = ["network-online.target"];
    after = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ["-${tv}/bin/tv keypress/PowerOn" "${tv}/bin/tv launch/tvinput.hdmi1"];
    };
  };

  powerManagement.resumeCommands = "${tv}/bin/tv keypress/PowerOn; ${tv}/bin/tv launch/tvinput.hdmi1";

  services.sunshine.settings.global_prep_cmd = builtins.toJSON [
    {
      do = "${pkgs.writeShellScript "tv-off" "${tv}/bin/tv keypress/PowerOff || true"}";
      undo = "";
    }
  ];

  environment.systemPackages = [
    tv
    pkgs.kdePackages.plasma-bigscreen
    pkgs.kdePackages.kdeconnect-kde
    pkgs.kdePackages.plasmatube
    pkgs.jellyfin-desktop
    (webapp "YouTube" "https://www.youtube.com/tv")
    (webapp "Navidrome" "https://navidrome.milberry.org")
    (webapp "Pinepods" "https://podcasts.milberry.org")
    (webapp "Seerr" "https://requests.lianas.org")
    (tile "Roku" "tv keypress/Home")
    (tile "SteamOS" "${pkgs.jovianPackages.steamos-manager}/bin/steamosctl switch-to-game-mode")
  ];
}
