{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    
    font = {
      name = "DanQing (base16)";
      size = 11;
    };

    settings = {
      macos_option_as_cmd = "yes";
      clear_all_shortcuts = "yes";
      update_check_interval = 0;
      cursor_shape = "beam";  # or "block", "underline"
      scrollback_lines = 200000;
      startup_session = "startup.session";

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

      # Performance defaults
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      # Dracula theme
      background = "#1e1f28";
      foreground = "#f8f8f2";
      cursor = "#bbbbbb";
      selection_background = "#44475a";
      selection_foreground = "#1e1f28";
      color0 = "#000000";
      color8 = "#545454";
      color1 = "#ff5555";
      color9 = "#ff5454";
      color2 = "#50fa7b";
      color10 = "#50fa7b";
      color3 = "#f0fa8b";
      color11 = "#f0fa8b";
      color4 = "#bd92f8";
      color12 = "#bd92f8";
      color5 = "#ff78c5";
      color13 = "#ff78c5";
      color6 = "#8ae9fc";
      color14 = "#8ae9fc";
      color7 = "#bbbbbb";
      color15 = "#ffffff";
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
      "cmd+d" = "launch --location=vsplit --cwd=current";
      "cmd+shift+d" = "launch --location=hsplit --cwd=current";

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
    launch --title ctl

    new_tab
    launch --title mon

    new_tab
    launch --title rmt

    new_tab
    launch --title perf
  '';
}
