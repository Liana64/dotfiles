# @desc: Helix editor — built-in LSP/tree-sitter/pickers, zero plugins
{...}: {
  flake.modules.homeManager.helix = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellScriptBin "helix-export" (builtins.readFile ../../bin/helix-export))
    ];

    programs.helix = {
      enable = true;

      settings = {
        theme = "kanagawa";

        editor = {
          line-number = "relative";
          cursorline = true;
          bufferline = "multiple";
          default-yank-register = "+";
          soft-wrap.enable = true;
          lsp.display-progress-messages = true;

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
