{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;

    plugins = with pkgs.vimPlugins; [
      bufferline-nvim
      colorizer
      cmp-nvim-lsp
      comment-nvim
      fidget-nvim
      gitsigns-nvim
      gruvbox-nvim
      lualine-nvim
      luasnip
      rustaceanvim
      snacks-nvim
      undotree
      nvim-autopairs
      nvim-cmp
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
      ${builtins.readFile ./nvim-core/keymaps.lua}
      ${builtins.readFile ./nvim-plugins/gruvbox.lua}
      ${builtins.readFile ./nvim-plugins/snacks.lua}
      ${builtins.readFile ./nvim-plugins/gitsigns.lua}
      ${builtins.readFile ./nvim-plugins/comment.lua}
      ${builtins.readFile ./nvim-plugins/autopairs.lua}
    '';
    };
}
