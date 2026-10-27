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
							local Kind = vim.lsp.protocol.CompletionItemKind
							local code_kinds = {
								[Kind.Function] = true,
								[Kind.Method] = true,
								[Kind.Constructor] = true,
								[Kind.Variable] = true,
								[Kind.Field] = true,
								[Kind.Property] = true,
								[Kind.Class] = true,
								[Kind.Interface] = true,
								[Kind.Module] = true,
								[Kind.Struct] = true,
								[Kind.Enum] = true,
								[Kind.EnumMember] = true,
								[Kind.Constant] = true,
								[Kind.TypeParameter] = true,
							}
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
								if item.kind == Kind.Snippet then
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
									if item.kind == Kind.Function
										or item.kind == Kind.Method
										or item.kind == Kind.Constructor
									then
										local name = bare_name(item)
										if name ~= "" and item.textEdit.newText:sub(1, #name) == name then
											item.textEdit.newText = name
											item.insertText = name
										end
									end
								end
							end
							-- Emmet (enabled for JSX/TSX) can return an HTML tag
							-- snippet with the same label as a real function, e.g.
							-- `add` -> `<add>${1}</add>`. Deduping by label alone
							-- kept whichever arrived first (usually Emmet), which
							-- silently replaced the function item and its docs.
							-- Rank real code symbols above snippets so the
							-- documented function survives.
							local function rank(item)
								local score = 0
								if item.kind ~= Kind.Snippet then
									score = score + 10
								end
								if code_kinds[item.kind] then
									score = score + 3
								end
								if item.documentation ~= nil and item.documentation ~= "" then
									score = score + 2
								end
								if type(item.detail) == "string" and item.detail ~= "" then
									score = score + 1
								end
								return score
							end
							return function(_, items)
								local by_label, order = {}, {}
								for _, item in ipairs(items) do
									strip(item)
									local label = item.label or ""
									local existing = by_label[label]
									if existing == nil then
										by_label[label] = item
										order[#order + 1] = label
									elseif rank(item) > rank(existing) then
										by_label[label] = item
									end
								end
								local result = {}
								for _, label in ipairs(order) do
									result[#result + 1] = by_label[label]
								end
								return result
							end
						end)(),
					},
				},
			},
			-- Show real code completions above Emmet tag snippets in
			-- JSX/TSX (both attach to those buffers).
			fuzzy = {
				sorts = {
					function(a, b)
						local a_emmet = a.client_name == "emmet_ls"
						local b_emmet = b.client_name == "emmet_ls"
						if a_emmet == b_emmet then
							return nil
						end
						return b_emmet
					end,
					"score",
					"sort_text",
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
