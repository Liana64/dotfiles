# @desc: Neovim config
{...}: {
  flake.modules.homeManager.nvim = {
    lib,
    pkgs,
    colors,
    ...
  }: let
    luaModules = [
      ./nvim-core/options.lua
      ./nvim-plugins/gruvbox.lua
      ./nvim-plugins/treesitter.lua
      ./nvim-plugins/orgmode.lua
      ./nvim-plugins/snacks.lua
      ./nvim-plugins/gitsigns.lua
      ./nvim-plugins/autopairs.lua
      ./nvim-plugins/blink.lua
      ./nvim-plugins/lsp.lua
      ./nvim-plugins/surround.lua
      ./nvim-plugins/colorizer.lua
      ./nvim-plugins/fidget.lua
      ./nvim-plugins/lualine.lua
      ./nvim-plugins/bufferline.lua
      ./nvim-plugins/todo-comments.lua
      ./nvim-plugins/trouble.lua
      ./nvim-plugins/which-key.lua
      ./nvim-core/keymaps.lua
    ];

    lspConfigs = [
      ./nvim-lsp/lua_ls.lua
      ./nvim-lsp/nixd.lua
      ./nvim-lsp/yamlls.lua
    ];

    modName = f: lib.removeSuffix ".lua" (baseNameOf f);
  in {
    xdg.cacheFile."nvim/.keep".text = "";

    xdg.configFile =
      lib.listToAttrs
      (
        map (f: lib.nameValuePair "nvim/lua/dotfiles/${modName f}.lua" {source = f;}) luaModules
        ++ map (f: lib.nameValuePair "nvim/lsp/${modName f}.lua" {source = f;}) lspConfigs
      );

    # TODO: Fix annoying bugs with snacks area management
    programs.neovim = {
      enable = true;

      plugins = with pkgs.vimPlugins; [
        blink-cmp
        bufferline-nvim
        fidget-nvim
        gitsigns-nvim
        gruvbox-nvim
        lualine-nvim
        luasnip
        nvim-autopairs
        nvim-colorizer-lua
        nvim-surround
        nvim-treesitter.withAllGrammars
        nvim-web-devicons
        orgmode
        rustaceanvim
        snacks-nvim
        todo-comments-nvim
        trouble-nvim
        undotree
        vim-sleuth
        which-key-nvim
      ];

      initLua = lib.concatLines (
        [''vim.g.palette = vim.json.decode([==[${builtins.toJSON colors.base16}]==])'']
        ++ map (f: ''require("dotfiles.${modName f}")'') luaModules
      );
    };
  };
}
