---@type vim.lsp.Config
return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_markers = { ".git" },
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      validate = true,
      keyOrdering = false,
      format = { enable = true },
      schemaStore = { enable = false, url = "" },
    },
  },
}
