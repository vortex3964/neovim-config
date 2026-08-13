-- REST client: run http requests from .http files (needs curl, which is
-- already present on the system)
return {
	{
		"rest-nvim/rest.nvim",
		ft = "http",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("rest-nvim").setup({})
		end,
	},
}
