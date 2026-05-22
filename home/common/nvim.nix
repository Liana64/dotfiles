{ pkgs, ... }:
{
  # Need this otherwise lazygit-nvim won't work
  xdg.cacheFile."nvim/.keep".text = "";

  # TODO: Fix annoying bugs with snacks area management
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      bufferline-nvim
      cmp-buffer
      cmp-nvim-lsp
      cmp-path
      cmp_luasnip
      comment-nvim
      fidget-nvim
      gitsigns-nvim
      gruvbox-nvim
      lazygit-nvim
      lualine-nvim
      luasnip
      rustaceanvim
      snacks-nvim
      undotree
      #neorg
      nvim-autopairs
      nvim-cmp
      nvim-colorizer-lua
      nvim-lspconfig
      nvim-surround
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      todo-comments-nvim
      trouble-nvim
      vim-illuminate
      vim-sleuth
      which-key-nvim
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./nvim-core/options.lua}
      ${builtins.readFile ./nvim-plugins/gruvbox.lua}
      ${builtins.readFile ./nvim-plugins/treesitter.lua}
      ${builtins.readFile ./nvim-plugins/snacks.lua}
      ${builtins.readFile ./nvim-plugins/gitsigns.lua}
      ${builtins.readFile ./nvim-plugins/comment.lua}
      ${builtins.readFile ./nvim-plugins/autopairs.lua}
      ${builtins.readFile ./nvim-plugins/cmp.lua}
      ${builtins.readFile ./nvim-plugins/lsp.lua}
      ${builtins.readFile ./nvim-plugins/surround.lua}
      ${builtins.readFile ./nvim-plugins/colorizer.lua}
      ${builtins.readFile ./nvim-plugins/fidget.lua}
      ${builtins.readFile ./nvim-plugins/lualine.lua}
      ${builtins.readFile ./nvim-plugins/bufferline.lua}
      ${builtins.readFile ./nvim-plugins/todo-comments.lua}
      ${builtins.readFile ./nvim-plugins/trouble.lua}
      ${builtins.readFile ./nvim-plugins/which-key.lua}
      ${builtins.readFile ./nvim-core/keymaps.lua}
    '';
    };
}
