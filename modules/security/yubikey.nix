# @desc: YubiKey (PAM/U2F)
{...}: {
  flake.modules.nixos.yubikey = {pkgs, ...}: let
    hardening = import ../_lib/systemd-hardening.nix;
  in {
    # Smart card daemon for YubiKey
    services.pcscd.enable = true;

    # ProtectHome=true would also mask /run/user; %t must stay writable for the
    # socket notifier that feeds the waybar indicator
    systemd.user.services.yubikey-touch-detector.serviceConfig =
      hardening.confined
      // {
        ProtectHome = "read-only";
        ReadWritePaths = "%t";
      };

    services.udev.packages = [pkgs.yubikey-personalization];

    programs.yubikey-touch-detector = {
      enable = true;
      libnotify = false;
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
    ];
  };
}
