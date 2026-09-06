# @desc: iamb — Matrix TUI client (lianas.org homeserver)
{...}: {
  flake.modules.homeManager.iamb = {config, ...}: {
    programs.iamb = {
      enable = true;

      settings = {
        default_profile = "lianas";

        profiles.lianas = {
          user_id = "@liana:lianas.org";
          url = "https://matrix.lianas.org";
        };

        settings = {
          log_level = "warn";

          username_display = "displayname";
          message_user_color = true;
          message_shortcode_display = true;
          reaction_display = true;
          reaction_shortcode_display = false;
          state_event_display = false;
          user_gutter_width = 24;

          read_receipt_display = true;
          read_receipt_send = true;
          typing_notice_display = true;
          typing_notice_send = true;

          normal_after_send = true;
          external_edit_file_suffix = ".md";
          open_command = ["xdg-open"];
          request_timeout = 60;
          mouse.enabled = false;

          notifications = {
            enabled = true;
            via = "desktop";
            show_message = true;
          };

          image_preview = {
            protocol.type = "kitty";
            size = {
              width = 66;
              height = 10;
            };
          };

          sort = {
            chats = ["favorite" "invite" "unread" "recent"];
            dms = ["favorite" "invite" "unread" "recent"];
            rooms = ["favorite" "invite" "lowpriority" "unread" "name"];
            spaces = ["favorite" "name"];
            members = ["power" "id"];
          };
        };

        dirs.downloads = config.xdg.userDirs.download;

        layout = {
          style = "config";
          tabs = [
            {window = "iamb://dms";}
            {window = "iamb://rooms";}
            {window = "iamb://unreads";}
          ];
        };

        macros.insert."jk" = "<Esc>";
      };
    };
  };
}
