-- function signature and parameters
return {
	"ray-x/lsp_signature.nvim",
	event = "InsertEnter",
	config = function()
		require("lsp_signature").setup({
			bind = true,
			border = "rounded",
			floating_window = true,
			hint_enable = true,
			hint_prefix = "󰡱 ",
			hi_parameter = "IncSearch", -- highlights the current parameter
			handler_opts = {
				border = "rounded",
			},
			auto_close_after = 5, -- closes after 5 seconds of inactivity
			toggle_key = "<C-s>", -- toggle signature window manually
		})
	end,
}

