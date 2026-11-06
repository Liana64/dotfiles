# @desc: YubiKey (PAM/U2F)
{...}: {
  flake.modules.nixos.yubikey = {pkgs, ...}: {
    # Smart card daemon for YubiKey
    services.pcscd.enable = true;

    services.udev.packages = [pkgs.yubikey-personalization];
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", SYMLINK+="yubikey-%k"
    '';

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
    ];
  };
}
