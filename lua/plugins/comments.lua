-- TODO comments
return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("todo-comments").setup({
			keywords = {
				FIX = {
					icon = "",
					color = "error",
					alt = { "FIXME", "BUG", "ISSUE" },
				},
				TODO = { icon = "", color = "info" },
				WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
				NOTE = { icon = "󰎞", color = "hint", alt = { } },
				IMPORTANT = {
					icon = "",
					color = "error",
					alt = { "IMP" },
				},
                DESC = { icon = "", color = "#20d91a", alt = { "DESCRIPTION", "INFO" } },
                CHANGE = { icon = "", color = "#d46b15", alt = { "DEPRECATED" } },
                DOC = { icon= "" , color = "#7e19e3" , alt={"DOC" , "Doc","doc code","Doc code","Doc end","doc end"} }
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

