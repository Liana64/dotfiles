{ lib, config, pkgs, ... }: {
  wayland.windowManager.sway = {
    enable = true;
    config = null;  # Don't generate default config
    extraConfigEarly = ''
      # Load custom config
      include ~/.config/sway/config
    '';
  };

  #home.packages = with pkgs; [
  #  fuzzel
  #  bemenu
  #  swaylock
  #  swayidle
  #  swaybg
  #  grim
  #  slurp
  #  wl-clipboard
  #  brightnessctl
  #  playerctl
  #  mako
  #];

  xdg.configFile."sway/config" = lib.mkForce {
    source = ./sway/config;
  };
  
  #services.mako.enable = true;
}
