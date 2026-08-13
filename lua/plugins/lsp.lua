return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup({
				ui = { border = "rounded" },
			})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			-- Apply capabilities to ALL servers, before mason-lspconfig enables them
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- basedpyright: drop-in pyright replacement with better hover docs.
			-- Tuned for speed + fewer false positives:
			--   - diagnosticMode "openFilesOnly": no full-project scan at startup
			--   - typeCheckingMode "basic": no pedantic type errors
			--   - autoSearchPaths disabled + indexing off: faster startup
			vim.lsp.config("basedpyright", {
				settings = {
					basedpyright = {
						analysis = {
							typeCheckingMode = "basic",
							diagnosticMode = "openFilesOnly",
							autoSearchPaths = false,
							indexing = false,
						},
					},
				},
			})

			-- Nicer hover popup: rounded border, clamped size so long
			-- docstrings wrap instead of clipping off-screen
			-- (vim.lsp.with is deprecated in 0.11+, so wrap the handler directly)
			vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
				config = vim.tbl_deep_extend("force", config or {}, {
					border = "rounded",
					max_width = 90,
					max_height = 30,
				})
				return vim.lsp.handlers.hover(err, result, ctx, config)
			end

			-- on_attach equivalent via LspAttach autocmd
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
					end
					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("gD", vim.lsp.buf.declaration, "Go to declaration")
					map("gr", vim.lsp.buf.references, "Go to references")
					map("gi", vim.lsp.buf.implementation, "Go to implementation")
					map("K", function()
						vim.lsp.buf.hover({ border = "rounded" })
					end, "Hover docs")
					map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("<leader>lf", vim.lsp.buf.format, "Format file")
					map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
					map("]d", vim.diagnostic.goto_next, "Next diagnostic")
					map("<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
				end,
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"ts_ls", "html", "cssls", "tailwindcss", "emmet_ls", "jsonls", "eslint",
					"gopls",
					"basedpyright",
					"lua_ls",
					"rust_analyzer",
					"clangd", "cmake",
					"sqlls",
					"bashls", "yamlls",
					"dockerls", "docker_compose_language_service",
					"marksman",
				},
				automatic_enable = true,
			})

			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					prefix = "●",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded" },
			})
		end,
	},
}