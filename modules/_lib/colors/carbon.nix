# @desc: Color palette: carbon
# based on https://github.com/nyoom-engineering/oxocarbon.nvim
{}: rec {
  name = "carbon";
  wallpaper = "/nix/dotfiles/share/wallpapers/flower.png";
  foreground = "#c0caf5";
  background = "#16161e";
  darker = "#0e0e14";
  accent = "#9ece6a";
  mbg = "#30354d";

  cursorColor = "#c0caf5";
  white = "#ffffff";
  comment = "#565f89";

  color0 = "#414868";
  gray = "#414868";

  color1 = "#f7768e";
  red = "#f7768e";

  color2 = "#9ece6a";
  lime = "#9ece6a";

  color3 = "#ff9e64";
  orange = "#ff9e64";

  yellow = "#e0af68";

  color4 = "#7dcfff";
  emerald = "#7dcfff";

  highlight = "#ec5fb5";
  highlightDim = "#9d3f78";

  color5 = "#bb9af7";
  pink = "#bb9af7";

  color6 = "#73daca";
  green = "#73daca";

  color7 = "#a9b1d6";
  tan = "#a9b1d6";

  # base16 palette consumed by stylix.
  base16 = {
    base00 = background;
    base01 = mbg;
    base02 = "#3b4261";
    base03 = comment;
    base04 = "#828bb8";
    base05 = foreground;
    base06 = "#cfd2e6";
    base07 = white;
    base08 = red;
    base09 = orange;
    base0A = yellow;
    base0B = accent;
    base0C = emerald;
    base0D = highlight;
    base0E = pink;
    base0F = "#7aa2f7";
  };
}
