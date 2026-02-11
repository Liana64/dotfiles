local Snacks = require("snacks")

require("snacks").setup({
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
    },
    preset = {
      header = [[
                                                                         
██╗     ██╗ █████╗ ███╗   ██╗ █████╗     ██╗      █████╗ ██████╗ ███████╗
██║     ██║██╔══██╗████╗  ██║██╔══██╗    ██║     ██╔══██╗██╔══██╗██╔════╝
██║     ██║███████║██╔██╗ ██║███████║    ██║     ███████║██████╔╝███████╗
██║     ██║██╔══██║██║╚██╗██║██╔══██║    ██║     ██╔══██║██╔══██╗╚════██║
███████╗██║██║  ██║██║ ╚████║██║  ██║    ███████╗██║  ██║██████╔╝███████║
╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝
                                                                         ]],
      keys = {
        { icon = " ", key = "e", desc = "New File", action = ":ene" },
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
  },

  indent = {
    enabled = true,
    char = "┊",
    scope = { enabled = true },
    animate = { enabled = false },
  },

  notifier = {
    enabled = true,
    timeout = 3000,
  },

  words = {
    enabled = true,
    debounce = 200,
  },

  bigfile = {
    enabled = true,
    size = 1024 * 1024,
  },

  picker = {
    enabled = true,
    sources = {
      files = {
        cmd = "fd",
        args = { "--type", "f", "--hidden", "--exclude", ".git" },
      },
      grep = {
        cmd = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob", "!.git",
        },
      },
    },
  },

  zen = {
    enabled = true,
    toggles = {
      dim = false,
      git_sign = true,
      diagnostics = true,
    },
  },

  terminal = {
    enabled = true,
    win = {
      position = "float",
    },
  },

  explorer = {
    enabled = true,
    replace_netrw = true,
    win = {
      list = {
        wo = {
          number = true,
          relativenumber = true,
        },
      },
    },
    follow_file = true,
    focus_file = true,
  },

  dim = { enabled = false },
  input = { enabled = true },
  select = { enabled = true },
  quickfile = { enabled = false },
  lazygit = { enabled = true },
  git = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  bufdelete = { enabled = true },
  image = { enabled = true },
  layout = { enabled = true },
  notify = { enabled = true },
  rename = { enabled = true },
  scope = { enabled = true },
  scratch = { enabled = true },
  toggle = { enabled = true },
  win = { enabled = true },
})
