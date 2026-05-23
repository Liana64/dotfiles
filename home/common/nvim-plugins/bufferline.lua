require("bufferline").setup({
  options = {
    close_command = function(n) Snacks.bufdelete(n) end,
    right_mouse_command = function(n) Snacks.bufdelete(n) end,
  },
})

-- Ephemeral buffers: wipe hidden buffers that are neither pinned nor edited.
-- Keep signal is deliberate (insert or save) so plugin touch-ups don't pin.
local function mark_kept(ev) vim.b[ev.buf].kept = true end
vim.api.nvim_create_autocmd("InsertEnter", { callback = mark_kept })
vim.api.nvim_create_autocmd("BufWritePost", { callback = mark_kept })

local function is_pinned(buf)
  local ok, pinned = pcall(function()
    return require("bufferline.groups")._is_pinned({ id = buf })
  end)
  return ok and pinned
end

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype ~= "" then return end
    local keep = vim.api.nvim_get_current_buf()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_valid(buf)
          and buf ~= keep
          and vim.bo[buf].buflisted
          and vim.bo[buf].buftype == ""
          and not vim.bo[buf].modified
          and not vim.b[buf].kept
          and #vim.fn.win_findbuf(buf) == 0
          and not is_pinned(buf)
        then
          pcall(vim.api.nvim_buf_delete, buf, {})
        end
      end
    end)
  end,
})
