vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.expandtab = true
opt.autoindent = true
opt.wrap = true
opt.tabstop = 2
opt.shiftwidth = 2

-- search
opt.ignorecase = true
opt.smartcase = true

-- visual
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- window splitting
opt.splitright = true
opt.splitbelow = true
