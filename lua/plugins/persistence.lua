-- Session persistence: save/restore your layout across restarts
return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {
		options = { "buffers", "win", "tabpages", "curdir" },
	},
	config = function(_, opts)
		require("persistence").setup(opts)

		vim.keymap.set("n", "<leader>qs", function()
			require("persistence").save()
		end, { desc = "Save session" })
		vim.keymap.set("n", "<leader>ql", function()
			require("persistence").load()
		end, { desc = "Load last session" })
		vim.keymap.set("n", "<leader>qd", function()
			require("persistence").stop()
		end, { desc = "Stop persisting session" })
	end,
}
