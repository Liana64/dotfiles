# @desc: YubiKey (PAM/U2F)
{...}: {
  flake.modules.nixos.yubikey = {pkgs, ...}: {
    # Smart card daemon for YubiKey
    services.pcscd.enable = true;

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
