--preview .md files in nvim
return {
	-- renders markdown nicely inside nvim
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},

	-- opens live preview in browser
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn.jobstart("cd app && npm install", { cwd = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim" })
		end,
		keys = {
			{ "<leader>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown preview open" },
			{ "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown preview stop" },
		},
	},
}

