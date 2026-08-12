local function location()
	-- This function existed in Lualine, I modified it to display the total
	-- number of selected characters spanning across multiple lines.
	local line = vim.fn.line(".")
	local col = vim.fn.charcol(".")

	local line_start = vim.fn.line("v")
	local line_end = vim.fn.line(".")

	if vim.fn.mode():find("[vV]") and line_end ~= line_start then
		return string.format("%d:%d:%d", line, col, vim.fn.wordcount().visual_chars)
	else
		return string.format("%d:%d", line, col)
	end
end

return {
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			sections = {
				lualine_y = {
					{ location, padding = { left = 1, right = 0 } },
				},
				lualine_z = {
					{ "progress", padding = { left = 1, right = 1 } },
				},
				-- Disable the default clock and replace it with word stats.
				lualine_c = {
					{
						"diagnostics",
						sources = { "nvim_lsp" },
						symbols = {
							error = " ",
							warn = " ",
							hint = " ",
							info = " ",
						},
					},
				},
			},
		},
	},
}

