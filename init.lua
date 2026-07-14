-- Make sure you have a nerd font

-- require the core setup for nvim
require("core.keymaps")
require("core.options")

-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

vim.g.have_nerd_font = true

local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- list of all the plugins were using
require("lazy").setup({
	require("plugins.telescope"),
	require("plugins.cheatsheet"),
	require("plugins.bufferline"),
	require("plugins.neotree"),
	require("plugins.git"),
	require("plugins.theme"),
	require("plugins.comments"),
	require("plugins.statusline"),
	require("plugins.markdown"),
	require("plugins.folding"),
	require("plugins.rand"),
	require("plugins.webview"),
	require("plugins.welcome"),
	require("plugins.lsp"),
	require("plugins.treesiter"),
	require("plugins.conform"),
	require("plugins.dap"),
	require("plugins.cmp"),
	require("plugins.lsp_signature"),
	require("plugins.database"),
	require("plugins.special"),
	require("plugins.csv"),
	require("plugins.pdf"),
    require("core.terminal"),
})
