 { ... }:
 {
   imports = [
     ./sway.nix
     ./swaybg.nix
     ./waybar.nix
     ./rofi.nix
     ./mako.nix
     #./i3status.nix
   ];

   programs.feh.enable = true;
 }
