# @desc: Helix keymaps mirroring nvim (space leader + C-x prefix)
{...}: {
  flake.modules.homeManager.helix = {
    programs.helix.settings.keys = {
      insert = {
        j.k = "normal_mode";
        C-s = ["normal_mode" ":write"];
      };

      select = {
        C-s = ["normal_mode" ":write"];
        "0" = "goto_line_start";
        "$" = "goto_line_end";
        "^" = "goto_first_nonwhitespace";
        G = "goto_last_line";
      };

      normal = {
        C-h = "jump_view_left";
        C-j = "jump_view_down";
        C-k = "jump_view_up";
        C-l = "jump_view_right";
        C-s = ":write";
        C-v = "select_mode";
        "0" = "goto_line_start";
        "$" = "goto_line_end";
        "^" = "goto_first_nonwhitespace";
        G = "goto_last_line";
        C = ["kill_to_line_end" "insert_mode"];
        backspace = "move_char_left";

        "]".h = "goto_next_change";
        "[".h = "goto_prev_change";

        space = {
          "+" = "increment";
          "-" = "decrement";
          e = "file_explorer";
          z.z = ":write-quit-all";
          q.q = ":quit-all!";

          g = {
            g = ":sh kitty --detach lazygit";
            s = "changed_file_picker";
          };

          s = {
            v = ":vsplit";
            h = ":hsplit";
            x = "wclose";
          };

          t = {
            n = "goto_next_buffer";
            p = "goto_previous_buffer";
            o = ":new";
            x = ":buffer-close";
            c = ":buffer-close-others";
          };

          l = {
            d = "goto_definition";
            r = "goto_reference";
            s = "symbol_picker";
            t = "workspace_diagnostics_picker";
          };
        };

        C-x = {
          C-f = "file_picker";
          C-g = "global_search";
          b = "buffer_picker";
          C-e = "file_explorer";
          C-j = "file_explorer";
          "2" = ":hsplit";
          "3" = ":vsplit";
          "0" = "wclose";
          "1" = "wonly";
          C-c = ":write-quit-all";

          g = {
            g = ":sh kitty --detach lazygit";
            s = "changed_file_picker";
          };

          l = {
            d = "goto_definition";
            r = "goto_reference";
            s = "symbol_picker";
            t = "workspace_diagnostics_picker";
          };
        };
      };
    };
  };
}
