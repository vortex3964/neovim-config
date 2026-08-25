return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	config = function()
		local wk = require("which-key")

		wk.setup({
			delay = 300,
		})

		wk.add({
			{ "<leader>f", group = "Find (Telescope)" },
			{ "<leader>g", group = "Git" },
			{ "<leader>gv", group = "Diffview" },
			{ "<leader>l", group = "LSP / Live server" },
			{ "<leader>d", group = "Debug / Delete" },
			{ "<leader>b", group = "Buffers" },
			{ "<leader>m", group = "Markdown" },
			{ "<leader>z", group = "Database" },
			{ "<leader>x", group = "Trouble diagnostics" },
			{ "<leader>n", group = "NPM packages" },
			{ "<leader>gs", group = "Go struct tags" },
			{ "<leader>gt", group = "Go tests" },
			{ "<leader>p", group = "Python / PDF" },
			{ "<leader>q", group = "Sessions" },
			{ "<leader>r", group = "Rest HTTP" },
			{ "<leader>c", group = "Code / CSV" },
			{ "<leader>s", group = "Splits" },
		})

		vim.keymap.set("n", "<leader>?", function()
			require("which-key").show()
		end, { desc = "Show all keymaps" })
	end,
}

