vim.api.nvim_create_autocmd("FileType", {
  ---@type fun(args: vim.api.keyset.create_autocmd.callback_args)
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
