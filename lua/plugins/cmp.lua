return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "1.*", -- use the pre-built binary release
		dependencies = {
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets", -- premade snippets for all languages
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			appearance = {
				nerd_font_variant = "mono",
			},
			snippets = {
				preset = "luasnip",
			},
			keymap = {
				preset = "none",
				["<Up>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Tab>"] = { "select_and_accept", "fallback" },
				["<C-space>"] = { "show", "fallback" },
				["<Esc>"] = { "hide", "fallback" },
			},
			completion = {
				list = {
					selection = { preselect = true, auto_insert = false },
				},
				menu = {
					border = "rounded",
					draw = {
						columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
					},
				},
				documentation = {
					auto_show = true,
					window = { border = "rounded" },
				},
				accept = {
					auto_brackets = { enabled = true },
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			signature = { enabled = true },
		},
		config = function(_, opts)
			-- Manually color blink.cmp to match ayu-dark, since the colorscheme
			-- doesn't reliably set the highlight groups blink expects.
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

			local function set_ayu_hl()
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

			set_ayu_hl()
			-- Re-apply if the colorscheme is reloaded/changed later
			vim.api.nvim_create_autocmd("ColorScheme", {
				callback = set_ayu_hl,
			})

			require("luasnip.loaders.from_vscode").lazy_load()
			require("blink.cmp").setup(opts)
		end,
	},
}
