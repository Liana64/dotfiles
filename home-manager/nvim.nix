{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      #alpha-nvim
      auto-pairs
      bufferline-nvim
      colorizer
      cmp-nvim-lsp
      comment-nvim
      fidget-nvim
      gitsigns-nvim
      gruvbox
      #indent-blankline-nvim
      #lazygit-nvim
      lualine-nvim
      luasnip
      snacks-nvim
      nvim-cmp
      nvim-lspconfig
      nvim-rustaceanvim
      #nvim-tree-lua
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      #substitute-nvim
      #telescope-nvim
      #telescope-ui-select-nvim
      todo-comments-nvim
      trouble-nvim
      vim-illuminate
      vim-sleuth
      which-key-nvim
    ];

    extraLuaConfig = ''
      ${builtins.readFile ./nvim/init.lua}
    '';
  };
}
