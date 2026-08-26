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
			-- Disable pull diagnostics to prevent duplicates with push diagnostics (Neovim 0.10+ issue)
			capabilities.textDocument.diagnostic = nil
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

		-- gopls: inlay hints for Go
		vim.lsp.config("gopls", {
			settings = {
				gopls = {
					hints = {
						assignVariableTypes = true,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = true,
					},
				},
			},
		})

		-- rust_analyzer: inlay hints for Rust
		vim.lsp.config("rust_analyzer", {
			settings = {
				["rust-analyzer"] = {
					inlayHints = {
						chainingHints = { enable = true },
						typeHints = { enable = true },
						parameterHints = { enable = true },
					},
				},
			},
		})

		-- clangd: inlay hints for C/C++
		vim.lsp.config("clangd", {
			settings = {
				clangd = {
					InlayHints = {
						Enabled = true,
						ParameterNames = true,
						DeducedParameters = true,
					},
				},
			},
		})

		-- lua_ls: inlay hints for Lua
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					hints = {
						enable = true,
						arrayIndex = "Enable",
						paramName = "All",
						semicolon = "All",
						setType = true,
					},
				},
			},
		})

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
					vim.lsp.buf.hover({ border = "rounded", max_width = 90, max_height = 30 })
				end, "Hover docs")
				map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
				map("<leader>ca", vim.lsp.buf.code_action, "Code action")
				map("<leader>lf", vim.lsp.buf.format, "Format via LSP")
				map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
				map("]d", vim.diagnostic.goto_next, "Next diagnostic")
				map("<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
				map("<leader>lc", vim.lsp.codelens.run, "Run CodeLens")

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client then
					-- Enable inlay hints for this buffer (if server supports it)
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
					end
					-- Enable CodeLens (run/test labels above functions)
					if client.server_capabilities.codeLensProvider then
						vim.api.nvim_create_autocmd({ "InsertLeave", "BufEnter", "CursorHold" }, {
							buffer = bufnr,
							callback = function()
								vim.lsp.codelens.enable(true, { bufnr = bufnr })
							end,
						})
						vim.lsp.codelens.enable(true, { bufnr = bufnr })
					end
					-- Enable reference highlighting (highlight usages on cursor hold)
					if client.server_capabilities.documentHighlightProvider then
						local hl_group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
						vim.api.nvim_clear_autocmds({ buffer = bufnr, group = hl_group })
						vim.api.nvim_create_autocmd("CursorHold", {
							buffer = bufnr,
							group = hl_group,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd("CursorMoved", {
							buffer = bufnr,
							group = hl_group,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end
			end,
		})

		-- Toggle inlay hints for the current buffer
		vim.keymap.set("n", "<leader>ti", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled, bufnr)
			if ok then
				vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
			end
		end, { desc = "Toggle inlay hints" })

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
				-- Exclude ts_ls: typescript-tools.nvim handles TS/JS instead
				automatic_enable = {
					exclude = { "ts_ls" },
				},
			})

			vim.diagnostic.config({
				virtual_text = {
					spacing = 4,
					prefix = "●",
				},
				virtual_lines = false,
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
