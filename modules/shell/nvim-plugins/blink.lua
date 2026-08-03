require("blink.cmp").setup({
  snippets = { preset = "luasnip" },

  fuzzy = {
    implementation = "rust",
    prebuilt_binaries = { download = false },
  },

  sources = {
    default = { "lsp", "snippets", "path", "buffer" },
  },

  completion = {
    list = {
      selection = { preselect = false, auto_insert = false },
    },
  },

  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
})
