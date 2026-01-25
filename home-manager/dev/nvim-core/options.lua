vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.expandtab = true
opt.autoindent = true
opt.wrap = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

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

-- mouse
opt.mousescroll = "ver:10,hor:6"

-- undo
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
