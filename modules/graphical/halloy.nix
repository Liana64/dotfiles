# @desc: Halloy IRC client
{...}: {
  flake.modules.homeManager.halloy = {colors, ...}: let
    inherit
      (colors.base16)
      base00
      base01
      base02
      base03
      base04
      base05
      base07
      base08
      base0A
      base0B
      base0C
      base0D
      base0E
      ;
  in {
    programs.halloy = {
      enable = true;

      settings = {
        theme = "palette";
        font.family = "JetBrainsMono Nerd Font";
        servers.liberachat = {
          nickname = "liana";
          server = "irc.libera.chat";
        };
      };

      themes.palette = {
        general = {
          background = base00;
          border = base07;
          horizontal_rule = base02;
          unread_indicator = base0A;
        };
        text = {
          primary = base05;
          secondary = base04;
          tertiary = base0A;
          success = base0B;
          error = base08;
        };
        buffer = {
          action = base0B;
          background = base00;
          background_text_input = base01;
          background_title_bar = base01;
          border = base03;
          border_selected = base07;
          code = base0E;
          highlight = base01;
          nickname = base0C;
          selection = base02;
          timestamp = base05;
          topic = base04;
          url = base0D;
          server_messages = {
            join = base0B;
            part = base08;
            quit = base08;
            default = base0C;
          };
        };
        buttons = {
          primary = {
            background = base00;
            background_hover = base02;
            background_selected = base03;
            background_selected_hover = base04;
          };
          secondary = {
            background = base01;
            background_hover = base02;
            background_selected = base03;
            background_selected_hover = base04;
          };
        };
      };
    };
  };
}
