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

		-- Keymaps (using <leader>f to avoid conflict with <leader>s split commands)
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep in project" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find open buffers" })
		vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Grep word under cursor" })
		vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Search diagnostics" })
		vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy search in current file" })
	end,
}

