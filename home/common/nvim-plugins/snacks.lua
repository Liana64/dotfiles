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

-- Keep a normal editor window so the explorer is never left as the only window
do
  local quitting = false
  vim.api.nvim_create_autocmd("ExitPre", {
    callback = function() quitting = true end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    callback = function()
      if quitting then return end
      vim.schedule(function()
        if quitting then return end
        local explorer, normal = nil, 0
        for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == "" then
            if vim.w[w].snacks_layout then
              explorer = w
            else
              normal = normal + 1
            end
          end
        end
        if explorer and normal == 0 then
          vim.cmd("botright vnew")
          vim.api.nvim_win_set_width(explorer, 40) -- snacks sidebar width
          vim.api.nvim_set_current_win(explorer)
        end
      end)
    end,
  })
end

Snacks.setup({
  indent = {
    enabled = true,
    indent = { char = "┊" },
    scope = { enabled = true, char = "┊" },
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

vim.api.nvim_set_hl(0, "SnacksIndent", { fg = "#3c3836" }) -- base02
vim.api.nvim_set_hl(0, "SnacksIndentScope", { fg = "#928374" }) -- base03
