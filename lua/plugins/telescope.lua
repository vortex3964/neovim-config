--fuzzily search for words files etch
return {
	"nvim-telescope/telescope.nvim",
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
					},
				},
				file_ignore_patterns = { "node_modules", ".git", ".venv" },
			},
		})

		pcall(telescope.load_extension, "fzf")

		-- Keymaps
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search word in project" })
		vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "Find open buffers" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search word under cursor" })
		vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "Recent files" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search diagnostics" })
		vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy search in current file" })
	end,
}

