{ pkgs, colors, ... }:
{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "DanQing (base16)";
      size = 11;
    };

    settings = {
      term = "xterm-256color";
      macos_option_as_cmd = "yes";
      clear_all_shortcuts = "yes";
      update_check_interval = 0;
      cursor_shape = "beam";  # or "block", "underline"
      scrollback_lines = 200000;

      # Mouse
      wheel_scroll_multiplier = 5;
      touch_scroll_multiplier = 3;

      # Window
      remember_window_size = "yes";
      window_padding_width = 8;

      # Notifications
      enable_audio_bell = "no";
      bell_on_tab = "no";

      # URLs
      detect_urls = "yes";
      url_style = "curly";
      open_url_with = "default";
    
      # Tabs
      tab_bar_edge = "bottom";
      tab_bar_style = "fade";

      # Performance
      repaint_delay = 5;
      input_delay = 1;
      sync_to_monitor = "no";

      # blueberry palette
      background = colors.background;
      foreground = colors.foreground;
      cursor = colors.cursorColor;
      selection_background = colors.gray;
      selection_foreground = colors.foreground;
      color0  = colors.color0;   color8  = colors.comment;
      color1  = colors.color1;   color9  = colors.color1;
      color2  = colors.color2;   color10 = colors.color2;
      color3  = colors.color3;   color11 = colors.color3;
      color4  = colors.color4;   color12 = colors.color4;
      color5  = colors.color5;   color13 = colors.color5;
      color6  = colors.color6;   color14 = colors.color6;
      color7  = colors.color7;   color15 = colors.white;
    };

    keybindings = {
      "shift+enter" = "send_text all \\e\\r";
      "ctrl+left" = "send_text all \\x1b[1;5D";
      "ctrl+right" = "send_text all \\x1b[1;5C";
      "alt+left" = "send_text all \\x1b[1;5D";
      "alt+right" = "send_text all \\x1b[1;5C";
      "ctrl+delete" = "send_text all \\x1bd\\x7f";
      #"ctrl+delete" = "send_text all \\x1bd";

      # Panes
      "cmd+d" = "launch --dont-take-focus --location=vsplit --cwd=current";
      "cmd+shift+d" = "launch --dont-take-focus --location=hsplit --cwd=current";

      # Tabs
      "ctrl+tab" = "next_tab";
      "ctrl+shift+tab" = "prev_tab";
      "cmd+h" = "neighboring_window left";
      "cmd+l" = "neighboring_window right";
      "cmd+j" = "neighboring_window down";
      "cmd+k" = "neighboring_window up";
      "cmd+1" = "goto_tab 1";
      "cmd+2" = "goto_tab 2";
      "cmd+3" = "goto_tab 3";
      "cmd+4" = "goto_tab 4";
      "cmd+5" = "goto_tab 5";
      "cmd+6" = "goto_tab 6";
      "cmd+7" = "goto_tab 7";
      "cmd+8" = "goto_tab 8";
      "cmd+9" = "goto_tab 9";
      "cmd+0" = "goto_tab 10";
      "ctrl+t" = "new_tab_with_cwd";
      "ctrl+w" = "close_tab";
      "ctrl+shift+i" = "set_tab_title";
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
  };
  xdg.configFile."kitty/startup.session".text = ''
    new_tab
    launch --title home

    new_tab
    launch --title dev

    new_tab
    launch --title ai

    new_tab
    launch --title mon

    new_tab
    launch --title ctl

    new_tab
    launch --title rmt

    new_tab
    launch --title perf
  '';
}
