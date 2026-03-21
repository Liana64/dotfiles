local Snacks = require("snacks")

-- Disable default netrw
vim.cmd("let g:loaded_netrw = 1")

-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     vim.schedule(function()
--       Snacks.explorer()
--     end)
--   end,
-- })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argc = vim.fn.argc()
    local arg = vim.fn.argv(0)
    vim.schedule(function()
      if argc > 0 and arg ~= "." then return end
      if argc == 0 then
        local old = vim.v.oldfiles
        if #old > 0 then
          vim.cmd("edit " .. vim.fn.fnameescape(old[1]))
        end
      end
      Snacks.explorer()
    end)
  end,
})

Snacks.setup({
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
      explorer = {
        win = {
          list = {
            wo = {
              number = true,
              relativenumber = true,
            },
          },
        },
        auto_close = false,
        jump = { close = false },
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
