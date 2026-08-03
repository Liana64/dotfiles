---@type vim.lsp.Config
local defaults = {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("*", defaults)
vim.lsp.enable({ "yamlls", "lua_ls", "nixd" })
