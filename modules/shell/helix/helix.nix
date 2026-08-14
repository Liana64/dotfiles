# @desc: Helix editor — built-in LSP/tree-sitter/pickers, zero plugins
{...}: {
  flake.modules.homeManager.helix = {pkgs, ...}: {
    programs.helix = {
      enable = true;

      extraPackages = with pkgs; [
        cargo
        rustc
        rust-analyzer
      ];

      themes.kanagawa-dim = {
        inherits = "kanagawa";
        "ui.virtual.indent-guide" = "sumiInk5";
      };

      settings = {
        theme = "kanagawa-dim";

        editor = {
          line-number = "relative";
          cursorline = true;
          bufferline = "multiple";
          color-modes = true;
          default-yank-register = "+";
          trim-final-newlines = true;
          soft-wrap.enable = true;
          auto-save.focus-lost = true;
          end-of-line-diagnostics = "hint";
          lsp.display-progress-messages = true;

          file-picker.hidden = false;
          indent-guides.render = true;
          inline-diagnostics.cursor-line = "warning";

          cursor-shape = {
            normal = "block";
            insert = "bar";
            select = "underline";
          };

          statusline.mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "VISUAL";
          };
        };
      };
    };
  };
}
