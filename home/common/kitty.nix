# @desc: Kitty terminal
{ colors, ... }:
{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "JetBrainsMono Nerd Font";
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

      # theme palette
      background = colors.background;
      foreground = colors.white;
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
      # Shell passthrough
      "shift+enter" = "send_text all \\e\\r";
      "ctrl+left"   = "send_text all \\x1b[1;5D";
      "ctrl+right"  = "send_text all \\x1b[1;5C";
      "ctrl+delete"    = "send_text all \\x1bd\\x7f";
      "ctrl+backspace" = "send_text all \\x1b\\x7f";

      # Scrollback
      "shift+page_up"   = "scroll_page_up";
      "shift+page_down" = "scroll_page_down";
      "shift+home"      = "scroll_home";
      "shift+end"       = "scroll_end";

      # Clipboard & font
      "ctrl+shift+c"     = "copy_to_clipboard";
      "ctrl+shift+v"     = "paste_from_clipboard";
      "ctrl+shift+plus"  = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
      "ctrl+shift+0"     = "change_font_size all 0";

      # Tabs
      "super+t"     = "new_tab_with_cwd";
      "super+i"     = "set_tab_title";
      "super+left"  = "prev_tab";
      "super+right" = "next_tab";
      "super+tab"       = "next_tab";
      "super+shift+tab" = "prev_tab";
      "super+shift+left"  = "move_tab_backward";
      "super+shift+right" = "move_tab_forward";
      "super+1" = "goto_tab 1";
      "super+2" = "goto_tab 2";
      "super+3" = "goto_tab 3";
      "super+4" = "goto_tab 4";
      "super+5" = "goto_tab 5";
      "super+6" = "goto_tab 6";
      "super+7" = "goto_tab 7";
      "super+8" = "goto_tab 8";
      "super+9" = "goto_tab 9";
      "super+0" = "goto_tab 10";

      # Panes
      "super+backslash" = "launch --dont-take-focus --location=vsplit --cwd=current";
      "super+minus"     = "launch --dont-take-focus --location=hsplit --cwd=current";
      "super+w"         = "close_window_with_confirmation";
      "super+shift+w"   = "close_window";
      "super+h" = "neighboring_window left";
      "super+j" = "neighboring_window down";
      "super+k" = "neighboring_window up";
      "super+l" = "neighboring_window right";
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
