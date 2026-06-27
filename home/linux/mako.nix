# @desc: Mako notification daemon
{ colors, ... }: {
  services.mako = {
    enable = true;

    settings = with colors; {
      default-timeout = 4000;
      ignore-timeout = false;
      icons = true;

      background-color = darker;
      border-color     = highlight;
      text-color       = foreground;
      border-size      = 1;
      border-radius    = 8;
      padding          = "10,14";
      font             = "Cantarell 11";
      progress-color   = "over ${highlight}33";

      # Muted red parallel to waybar @alert = mix(color0, red, 0.5).
      "urgency=high" = {
        background-color = "#93504c";
      };
    };
  };
}
