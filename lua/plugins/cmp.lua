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
				auto_brackets = {
					enabled = true,
					-- blink blocks auto-brackets for some filetypes by default
					-- (it expects the server to supply the parens), but since we
					-- strip server parens/args down to a bare name, re-allow it
					-- for every language in use so Tab always gives foo()
					-- with the cursor inside.
					force_allow_filetypes = {
						"c", "cpp", -- clangd
						"rust", -- rust_analyzer (blocked by blink default)
						"sql", -- sqlls (blocked by blink default)
						"go", -- gopls
						"python", -- pyright
						"lua", -- lua_ls
						"typescript", "typescriptreact", "javascript", "javascriptreact", -- typescript-tools
						"html", "css", "scss", "less", "json", "jsonc", -- web stack
						"sh", "bash", -- bashls
						"yaml", -- yamlls
						"cmake", -- cmake
						"markdown", -- marksman
						"dockerfile", -- dockerls
					},
				},
			},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				providers = {
					lsp = {
						transform_items = (function()
							local seen = {}
							local last_cursor = nil
							local function bare_name(item)
								local label = item.label or ""
								return label:match("^[^%(%s]+") or label
							end
							-- Strip `foo(args)` / `foo()` down to bare `foo` so
							-- blink's auto_brackets inserts `()` with cursor inside.
							-- Runs on both initial completions AND resolve results
							-- (blink re-runs transform_items after resolve).
							local function strip(item)
								-- Real snippet items (loops, etc.): leave alone.
								if item.kind == vim.lsp.protocol.CompletionItemKind.Snippet then
									return
								end
								if item.insertTextFormat == vim.lsp.protocol.InsertTextFormat.Snippet then
									local name = bare_name(item)
									item.insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText
									item.insertText = name
									item.textEditText = nil
									if item.textEdit ~= nil then
										item.textEdit.newText = name
									end
								elseif item.textEdit ~= nil and item.textEdit.newText ~= nil then
									if item.kind == vim.lsp.protocol.CompletionItemKind.Function
										or item.kind == vim.lsp.protocol.CompletionItemKind.Method
										or item.kind == vim.lsp.protocol.CompletionItemKind.Constructor
									then
										local name = bare_name(item)
										if name ~= "" and item.textEdit.newText:sub(1, #name) == name then
											item.textEdit.newText = name
											item.insertText = name
										end
									end
								end
							end
							return function(ctx, items)
								-- Reset seen when cursor moves (new completion session)
								local cursor = vim.api.nvim_win_get_cursor(0)
								local cursor_key = cursor[1] .. ":" .. cursor[2]
								if cursor_key ~= last_cursor then
									seen = {}
									last_cursor = cursor_key
								end
								for _, item in ipairs(items) do
									strip(item)
								end
								return vim.iter(items)
									:filter(function(item)
										if item.label and seen[item.label] then
											return false
										end
										seen[item.label] = true
										return true
									end)
									:totable()
							end
						end)(),
					},
				},
			},
			signature = {
				enabled = true,
				window = { border = "rounded" },
			},
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
