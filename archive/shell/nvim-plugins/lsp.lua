local builtin_highlight = vim.lsp.handlers["textDocument/documentHighlight"]

---@type vim.lsp.Config
local defaults = {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
  handlers = {
    ["textDocument/documentHighlight"] = function(err, result, ctx, cfg)
      if not vim.api.nvim_buf_is_loaded(ctx.bufnr) then return end
      return builtin_highlight(err, result, ctx, cfg)
    end,
  },
}

vim.lsp.config("*", defaults)
vim.lsp.enable({ "yamlls", "lua_ls", "nixd" })
