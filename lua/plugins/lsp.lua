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

			-- pyright: optimized for data science / AI / backend Python work
			--   - useLibraryCodeForTypes: analyze library code for better completions
			--     (critical for numpy, pandas, torch, etc.)
			--   - autoSearchPaths: find all project files for accurate completions
			--   - diagnosticMode "openFilesOnly": don't scan entire workspace at startup
			--   - typeCheckingMode "standard": catches real type issues without noise
			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							typeCheckingMode = "standard",
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "openFilesOnly",
							inlayHints = {
								variableTypes = true,
								functionReturnTypes = true,
								parameterTypes = true,
								genericTypes = true,
							},
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
					map("<leader>lf", vim.lsp.buf.format, "Format via LSP")
					map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
					map("]d", vim.diagnostic.goto_next, "Next diagnostic")
					map("<leader>ld", vim.diagnostic.open_float, "Show diagnostic")

				end,
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"html", "cssls", "tailwindcss", "emmet_ls", "jsonls", "eslint",
					"gopls",
					"pyright",
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
	-- TypeScript-tools: richer TS/JS support than ts_ls
	-- (inlay hints, auto-organize imports, file operations, etc.)
	{
		"pmizio/typescript-tools.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
		config = function()
			require("typescript-tools").setup({
				settings = {
					tsdiagnostics = {
						inlayHints = {
							parameterNames = { enabled = "all" },
							parameterTypes = { enabled = "all" },
							variableTypes = { enabled = true },
							propertyDeclarationTypes = { enabled = true },
							functionReturnTypes = { enabled = true },
							genericTypes = { enabled = true },
						},
					},
					tsserver_format_options = {
						indentSize = 2,
						tabSize = 2,
						convertTabsToSpaces = false,
					},
				},
			})

		end,
	},
}
