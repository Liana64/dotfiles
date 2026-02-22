

-- Vim options
local opt = vim.opt
opt.relativenumber = true
opt.number = true
opt.expandtab = true
opt.autoindent = true
opt.wrap = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Visual
opt.cursorline = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- Window splitting
opt.splitright = true
opt.splitbelow = true

-- Mouse
opt.mousescroll = "ver:10,hor:6"

-- Undo
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"
