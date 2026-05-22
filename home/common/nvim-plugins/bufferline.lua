require("bufferline").setup({
  options = {
    close_command = function(n) Snacks.bufdelete(n) end,
    right_mouse_command = function(n) Snacks.bufdelete(n) end,
  },
})

local groups = require("bufferline.groups")

-- Ephemeral buffers: wipe hidden buffers that are neither pinned nor edited
vim.api.nvim_create_autocmd("BufModifiedSet", {
  callback = function(ev)
    if vim.bo[ev.buf].modified then
      vim.b[ev.buf].kept = true
    end
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype ~= "" then
      return
    end
    local keep = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          buf ~= keep
          and vim.bo[buf].buflisted
          and vim.bo[buf].buftype == ""
          and not vim.bo[buf].modified
          and not vim.b[buf].kept
          and #vim.fn.win_findbuf(buf) == 0
          and not groups._is_pinned({ id = buf })
        then
          pcall(vim.api.nvim_buf_delete, buf, {})
        end
      end
    end)
  end,
})
