# @desc: Color palette: blueberry
{}: rec {
  name = "blueberry";
  wallpaper = "/nix/dotfiles/share/wallpapers/flower.png";
  foreground = "#fbf1c7";
  background = "#222222";
  darker = "#18182c";
  accent = "#a9b665";
  mbg = "#282828";

  cursorColor = "#fbf1c7";
  white = "#ffffff";
  comment = "#928374";

  color0 = "#3c3836";
  gray = "#3c3836";

  color1 = "#ea6962";
  red = "#ea6962";

  color2 = "#a9b665";
  lime = "#a9b665";

  color3 = "#e79a4e";
  orange = "#e79a4e";

  yellow = "#d8a657";

  color4 = "#7daea3";
  emerald = "#7daea3";

  highlight = "#5b6ee8";
  highlightDim = "#4654b8";

  color5 = "#d3869b";
  pink = "#d3869b";

  color6 = "#89b482";
  green = "#89b482";

  color7 = "#d4be98";
  tan = "#d4be98";

  # base16 palette consumed by stylix.
  base16 = {
    base00 = background;
    base01 = mbg;
    base02 = gray;
    base03 = comment;
    base04 = "#bdae93";
    base05 = "#fffefb";
    base06 = "#ddc7a1";
    base07 = white;
    base08 = red;
    base09 = orange;
    base0A = yellow;
    base0B = accent;
    base0C = green;
    base0D = highlight;
    base0E = pink;
    base0F = emerald;
  };
}
