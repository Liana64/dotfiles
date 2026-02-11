require("neorg").setup {
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = {},
    ["core.dirman"] = {
      config = {
        workspaces = {
          Notebook = "~/Sync/Notebook",
        },
        default_workspace = "Notebook",
      },
    },
    ["core.completion"] = {
      config = {
        engine = "nvim-cmp",
      },
    },
    ["core.keybinds"] = {
      config = {
        default_keybinds = true,
      },
    },
  }
}
