-- Manual ayu-dark colors for blink.cmp windows.
--
-- These are defined at startup (not only when blink.cmp loads) so the LSP
-- hover window can reuse the exact same panel colors as the completion
-- documentation/signature windows. Without this, `K` before ever entering
-- insert mode would use the generic NormalFloat/FloatBorder colors and look
-- different from the completion popups.

local M = {}

local ayu = {
	bg = "#0A0E14",
	bg_panel = "#0D1017",
	bg_selection = "#273747",
	fg = "#B3B1AD",
	comment = "#4D5566",
	border = "#11151C",
	accent = "#E6B450",
	blue = "#59C2FF",
	green = "#AAD94C",
}

function M.setup()
	vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = ayu.bg_panel, fg = ayu.fg })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = ayu.bg_panel, fg = ayu.border })
	vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = ayu.bg_selection, fg = ayu.fg, bold = true })
	vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = ayu.bg_panel, fg = ayu.fg })
	vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = ayu.bg_panel, fg = ayu.border })
	vim.api.nvim_set_hl(0, "BlinkCmpDocSeparator", { fg = ayu.border })
	vim.api.nvim_set_hl(0, "BlinkCmpLabel", { fg = ayu.fg })
	vim.api.nvim_set_hl(0, "BlinkCmpLabelMatch", { fg = ayu.accent, bold = true })
	vim.api.nvim_set_hl(0, "BlinkCmpLabelDetail", { fg = ayu.comment })
	vim.api.nvim_set_hl(0, "BlinkCmpLabelDescription", { fg = ayu.comment })
	vim.api.nvim_set_hl(0, "BlinkCmpKind", { fg = ayu.blue })
	vim.api.nvim_set_hl(0, "BlinkCmpSource", { fg = ayu.comment })
	vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = ayu.comment, italic = true })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelp", { bg = ayu.bg_panel, fg = ayu.fg })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpBorder", { bg = ayu.bg_panel, fg = ayu.border })
	vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter", { fg = ayu.green, bold = true })
end

M.setup()
-- Re-apply if the colorscheme is reloaded/changed later.
vim.api.nvim_create_autocmd("ColorScheme", { callback = M.setup })

return M
