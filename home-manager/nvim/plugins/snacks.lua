require("snacks").setup({
	dashboard = {
		enabled = true,
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			{ section = "startup" },
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
				{ icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
				{ icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
				{ icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
				{ icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
				{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
			},
		},
	},

	indent = {
		enabled = true,
		char = "┊",
		scope = { enabled = true },
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
		size = 1024 * 1024, -- 1MB
	},

	dim = {
		enabled = true,
		scope = {
			min_size = 5,
			max_size = 20,
		},
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
					"--glob",
					"!.git",
				},
			},
		},
	},

	zen = {
		enabled = true,
		toggles = {
			dim = true,
			git_signs = true,
			diagnostics = true,
		},
	},

	terminal = {
		enabled = true,
		win = {
			position = "float",
		},
	},

	input = { enabled = true },
	select = { enabled = true },
	quickfile = { enabled = true },
	lazygit = { enabled = true },
	explorer = { enabled = true },
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
	terminal = { enabled = true },
	toggle = { enabled = true },
	win = { enabled = true },

	--animate = { enabled = true },
	--profiler = { enabled = true },
	--debug = { enabled = true },
})

local Snacks = require("snacks")

vim.keymap.set("n", "<leader>ee", function()
	Snacks.explorer()
end, { desc = "File Explorer" })
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gb", function()
	Snacks.git.blame_line()
end, { desc = "Git Blame Line" })
vim.keymap.set("n", "<leader>nh", function()
	Snacks.notifier.hide()
end, { desc = "Hide Notifications" })
vim.keymap.set("n", "<leader>nl", function()
	Snacks.notifier.show_history()
end, { desc = "Notification History" })
