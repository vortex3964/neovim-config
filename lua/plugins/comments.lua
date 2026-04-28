-- TODO comments
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("todo-comments").setup({
			keywords = {
				FIX = {
					icon = "!",
					color = "error",
					alt = { "FIXME", "BUG", "IMPORTANT", "ISSUE" },
				},
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
				IMPORTANT = {
					icon = "! ",
					color = "error",
					alt = { "IMP" },
				},
			},
		})

		-- Keymaps
		vim.keymap.set("n", ">t", function()
			require("todo-comments").jump_next()
		end, { desc = "Next todo comment" })

		vim.keymap.set("n", "<t", function()
			require("todo-comments").jump_prev()
		end, { desc = "Previous todo comment" })
	end,
}