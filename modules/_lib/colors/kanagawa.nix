# @desc: Color palette: kanagawa
# based on https://github.com/rebelot/kanagawa.nvim (wave)
{}: rec {
  name = "kanagawa";
  wallpaper = "/nix/dotfiles/share/wallpapers/flower.png";
  foreground = "#dcd7ba";
  background = "#1f1f28";
  darker = "#16161d";
  accent = "#98bb6c";
  mbg = "#2a2a37";

  cursorColor = "#dcd7ba";
  white = "#ffffff";
  comment = "#727169";

  color0 = "#363646";
  gray = "#363646";

  color1 = "#ff5d62";
  red = "#ff5d62";

  color2 = "#98bb6c";
  lime = "#98bb6c";

  color3 = "#ffa066";
  orange = "#ffa066";

  yellow = "#e6c384";

  color4 = "#7aa89f";
  emerald = "#7aa89f";

  highlight = "#7e9cd8";
  highlightDim = "#658594";

  color5 = "#957fb8";
  pink = "#957fb8";

  color6 = "#7fb4ca";
  green = "#7fb4ca";

  color7 = "#c8c093";
  tan = "#c8c093";

  # base16 palette consumed by stylix.
  base16 = {
    base00 = background;
    base01 = mbg;
    base02 = "#223249";
    base03 = comment;
    base04 = tan;
    base05 = foreground;
    base06 = "#f2ecbc";
    base07 = white;
    base08 = red;
    base09 = orange;
    base0A = yellow;
    base0B = accent;
    base0C = green;
    base0D = highlight;
    base0E = pink;
    base0F = "#d27e99";
  };
}
