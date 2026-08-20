# @desc: Helix keymaps mirroring nvim (space leader + C-x prefix)
{...}: let
  git = {
    g = ":sh kitty --detach lazygit";
    f = ":sh kitty --detach lazygit -f '%{buffer_name}'";
    s = "changed_file_picker";
  };

  tabs = let
    prev = "goto_previous_buffer";
    next = "goto_next_buffer";
  in {
    C-h = prev;
    C-left = prev;
    C-k = prev;
    C-up = prev;
    C-l = next;
    C-right = next;
    C-j = next;
    C-down = next;
  };

  lsp = {
    a = "code_action";
    d = "goto_definition";
    k = "hover";
    r = "goto_reference";
    R = "rename_symbol";
    s = "symbol_picker";
    t = "workspace_diagnostics_picker";
  };
in {
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

      normal =
        tabs
        // {
          C-s = ":write";
          C-r = "redo";
          C-v = "select_mode";
          C-n = "copy_selection_on_next_line";
          C-p = "copy_selection_on_prev_line";
          "0" = "goto_line_start";
          "$" = "goto_line_end";
          "^" = "goto_first_nonwhitespace";
          G = "goto_last_line";
          C = ["kill_to_line_end" "insert_mode"];
          backspace = "move_char_left";

          "]".h = "goto_next_change";
          "[".h = "goto_prev_change";

          C-w = {
            h = "jump_view_left";
            j = "jump_view_down";
            k = "jump_view_up";
            l = "jump_view_right";
          };

          space = {
            "+" = "increment";
            "-" = "decrement";
            e = "file_explorer";
            z.z = ":write-quit-all";
            q.q = ":quit-all!";
            g = git;
            l = lsp;

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
            x = ":buffer-close";
            c = ":buffer-close-others";
            C-c = ":write-quit-all";
            r = ":reload-all";
            g = git;
            l = lsp;
          };
        };
    };
  };
}
