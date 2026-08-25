return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = "BufReadPre",
	config = function()
		require("nvim-treesitter").setup({
			ensure_installed = {
				"javascript",
				"typescript",
				"tsx",
				"go",
				"rust",
				"c",
				"cpp",
				"python",
				"html",
				"css",
				"json",
				"yaml",
				"bash",
				"markdown",
				"markdown_inline",
				"lua",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}

