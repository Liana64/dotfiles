vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus left" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus down" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus up" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus right" })

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })
keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undotree" })

keymap.set("n", "<leader>zz", "<cmd>wqa<cr>", { desc = "Write and close everything right now" })
keymap.set("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Dangerously close everything right now" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- LSP
keymap.set("n", "<leader>ld", function() Snacks.picker.lsp_definitions() end, { desc = "Go to Definition" })
keymap.set("n", "<leader>lr", function() Snacks.picker.lsp_references() end, { desc = "References" })
keymap.set("n", "<leader>ls", function() Snacks.picker.lsp_symbols() end, { desc = "Document Symbols" })
keymap.set("n", "<leader>lt", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })

-- Snacks
keymap.set("n", "<leader>e", function() Snacks.explorer() end, { desc = "File Explorer" })
keymap.set("n", "<leader>nt", function() Snacks.notifier.hide() end, { desc = "Hide Notifications" })
keymap.set("n", "<leader>nl", function() Snacks.notifier.show_history() end, { desc = "Notification History" })
keymap.set("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find Files" })
keymap.set("n", "<leader>fs", function() Snacks.picker.grep() end, { desc = "Search Text" })
keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
keymap.set("n", "<leader>fh", function() Snacks.picker.help() end, { desc = "Help" })
keymap.set("n", "<leader>fr", function() Snacks.picker.recent() end, { desc = "Recent Files" })
keymap.set("n", "<leader>nz", function() Snacks.zen() end, { desc = "Zen Mode" })

-- Git
keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
keymap.set("n", "<leader>gs", function() Snacks.picker.git_status() end, { desc = "Git Status" })
keymap.set("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
