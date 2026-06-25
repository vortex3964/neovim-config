return {
	-- Auto close brackets, quotes, etc.
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({
				check_ts = true,
			})
		end,
	},

	-- Undo tree visualizer
	{
		"mbbill/undotree",
		cmd = "UndotreeToggle",
		keys = {
			{ "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle undo tree" },
		},
	},

	-- Indent lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = "BufReadPre",
		config = function()
			require("ibl").setup({
				indent = { char = "│" },
				scope = { enabled = true },
			})
		end,
	},

	-- Surround: add/change/delete surrounding brackets, quotes, tags
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup()
		end,
	},

	-- Comment: gc to comment/uncomment lines and blocks
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Aerial: sidebar showing functions/classes for navigation
	{
		"stevearc/aerial.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>a", "<cmd>AerialToggle<CR>", desc = "Toggle aerial outline" },
		},
		config = function()
			require("aerial").setup({
				on_attach = function(bufnr)
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr, desc = "Prev symbol" })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr, desc = "Next symbol" })
				end,
			})
		end,
	},

	-- Flash: Ctrl+f to search with labeled jumps
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		config = function()
			require("flash").setup({
				modes = {
					search = { enabled = true }, -- enhances / search
					char = { enabled = false }, -- disable f/t override
				},
			})
		end,
		keys = {
			{
				"<C-f>",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash search",
			},
		},
	},

	-- LSPKind: VS Code style icons in completion menu
	{
		"onsails/lspkind.nvim",
		event = "InsertEnter",
		config = function()
			require("lspkind").init({
				mode = "symbol_text",
				preset = "codicons",
			})
		end,
	},

}
