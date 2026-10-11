return {
	-- your themes (kept lazy so only the active colorscheme loads at startup;
	-- Themery loads the selected one on demand via :Themery)
	{ "folke/tokyonight.nvim", lazy = true },
	{ "catppuccin/nvim", name = "catppuccin", lazy = true },
	{ "rose-pine/neovim", name = "rose-pine", lazy = true },
	{ "rebelot/kanagawa.nvim", lazy = true },
	{ "EdenEast/nightfox.nvim", lazy = true },
	{ "Shatur/neovim-ayu", name = "ayu", lazy = true },
	{
		"bluz71/vim-moonfly-colors",
		name = "moonfly",
		lazy = false,
		priority = 1000, -- loads first before other plugins
		config = function()
			vim.cmd.colorscheme("moonfly")
		end,
	},

	-- theme manager (eager: it restores the saved theme at startup, which
	-- requires firing ColorSchemePre to autoload lazy theme plugins --
	-- nested inside VeryLazy that autocmd is suppressed, restore fails
	-- with E185 and the fallback overwrites the saved pick)
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			-- Guarded: a malformed state file (e.g. hand-edited, missing
			-- fields) makes Themery's bootstrap error; keep startup clean
			-- and hold the moonfly default instead of a stacktrace.
			local ok, themery = pcall(require, "themery")
			if not ok then
				return
			end
			themery.setup({
				themes = {
					{ name = "Moonfly", colorscheme = "moonfly" },
					{ name = "Tokyo Night", colorscheme = "tokyonight" },
					{ name = "Tokyo Night Storm", colorscheme = "tokyonight-storm" },
					{ name = "Tokyo Night Moon", colorscheme = "tokyonight-moon" },
					{ name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
					{ name = "Catppuccin Latte", colorscheme = "catppuccin-latte" },
					{ name = "Rose Pine", colorscheme = "rose-pine" },
					{ name = "Kanagawa", colorscheme = "kanagawa" },
					{ name = "Nightfox", colorscheme = "nightfox" },
					{ name = "Ayu Dark", colorscheme = "ayu-dark" },
					{ name = "Ayu Mirage", colorscheme = "ayu-mirage" },
				},
				livePreview = true,
			})

			vim.keymap.set("n", "<leader>th", "<cmd>Themery<CR>", { desc = "Theme picker" })
		end,
	},
}

