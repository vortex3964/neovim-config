return {
	{
		"mason-org/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog" },
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("mason").setup({
				ui = { border = "rounded" },
			})
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			-- NOTE: do NOT require("blink.cmp") here. That forces the
			-- completion engine (+ LuaSnip + snippets) to load at startup
			-- even though blink.cmp is lazy on InsertEnter. These are the
			-- same capabilities blink advertises (see
			-- blink.cmp.sources.lib.get_lsp_capabilities), inlined so LSP
			-- servers start with full completion support without loading blink.
			local capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
				textDocument = {
					completion = {
						completionItem = {
							snippetSupport = true,
							commitCharactersSupport = false,
							documentationFormat = { "markdown", "plaintext" },
							deprecatedSupport = true,
							preselectSupport = false,
							tagSupport = { valueSet = { 1 } },
							insertReplaceSupport = true,
							resolveSupport = {
								properties = {
									"documentation",
									"detail",
									"additionalTextEdits",
									"command",
									"data",
								},
							},
							insertTextModeSupport = {
								valueSet = { 1 },
							},
							labelDetailsSupport = true,
						},
						completionList = {
							itemDefaults = {
								"commitCharacters",
								"editRange",
								"insertTextFormat",
								"insertTextMode",
								"data",
							},
						},
						contextSupport = true,
						insertTextMode = 1,
					},
				},
			})
			-- We complete functions as bare names (foo) and let blink.cmp's
			-- accept.auto_brackets add () with the cursor inside.
			-- If the client advertises snippetSupport, clangd (and others)
			-- reply with snippet items like foo(${1:int x}, ...) and even
			-- re-add them on completionItem/resolve, bypassing any menu
			-- filtering. Disabling it forces PlainText completions.
			capabilities.textDocument.completion.completionItem.snippetSupport = false
			-- NOTE: do NOT nil out capabilities.textDocument.diagnostic here.
			-- That disables LSP pull diagnostics, and then every server
			-- spams "server_request: no handler found for
			-- workspace/diagnostic/refresh" (the exact WARN filling your log).
			-- Neovim 0.11+ handles pull diagnostics natively with no
			-- duplicates, so pass blink capabilities through untouched.
			-- Apply capabilities to ALL servers, before mason-lspconfig enables them
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Pyright does NOT auto-discover a project's ./venv (or ./.venv) the
			-- way the VS Code Python extension does. Without an interpreter it
			-- falls back to the system Python, so every third-party import is
			-- "could not be resolved" and hover/completion has no docstrings for
			-- library functions (numpy, sklearn, ...). Resolve the venv from the
			-- buffer's project before the client starts.
			local function project_python(bufnr)
				local file = vim.api.nvim_buf_get_name(bufnr)
				local dir = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
				local root = vim.fs.root(bufnr, {
					"pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg",
					"requirements.txt", "Pipfile", ".git",
				}) or dir
				local candidates = {
					root .. "/.venv/bin/python",
					root .. "/venv/bin/python",
					root .. "/env/bin/python",
					dir .. "/.venv/bin/python",
					dir .. "/venv/bin/python",
				}
				if vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV ~= "" then
					table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python")
				end
				if vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX ~= "" then
					table.insert(candidates, vim.env.CONDA_PREFIX .. "/bin/python")
				end
				for _, python in ipairs(candidates) do
					if vim.fn.executable(python) == 1 then
						return python
					end
				end
			end

			-- Runs before vim.lsp.enable's FileType handler (registered below in
			-- mason-lspconfig.setup), so pyright starts with the right
			-- interpreter instead of being restarted after attaching.
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "python",
				callback = function(args)
					local python = project_python(args.buf)
					if not python then
						python = vim.fn.exepath("python3")
					end
					if python == "" then
						python = vim.fn.exepath("python")
					end
					if python ~= "" then
						-- Overwriting pythonPath each time also prevents a venv
						-- from a previously opened project leaking into this one.
						vim.lsp.config("pyright", {
							settings = {
								python = {
									pythonPath = python,
								},
							},
						})
					end
				end,
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
							-- pyright's real option names (parameterTypes and
							-- genericTypes don't exist, so they were ignored).
							inlayHints = {
								variableTypes = true,
								functionReturnTypes = true,
								callArgumentNames = true,
								pytestParameters = true,
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

		-- clangd: inlay hints are a *command-line* flag, not a
		-- `settings` table (clangd ignores `settings.clangd.InlayHints`,
		-- so the old block was a silent no-op). Pass --inlay-hints here.
		-- NOTE: do NOT pass --function-arg-placeholders here. That flag
		-- makes clangd expand foo() into foo(int x, int y) on completion.
		-- Without it, clangd completes just the name and blink.cmp's
		-- accept.auto_brackets adds () with the cursor inside.
		vim.lsp.config("clangd", {
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
				"--fallback-style=llvm",
				"--inlay-hints=true",
			},
		})

		-- lua_ls: inlay hints for Lua
		-- NOTE: the server schema is `Lua.hint` (singular). The old
		-- `Lua.hints` (plural) key was silently ignored.
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					hint = {
						enable = true,
						arrayIndex = "Enable",
						paramName = "All",
						semicolon = "All",
						setType = true,
					},
				},
			},
		})

		-- emmet_ls: expand/completions for html/css AND jsx/tsx (React/Electron
		-- renderer code). Explicit filetypes so abbreviations work in .jsx/.tsx.
		vim.lsp.config("emmet_ls", {
			filetypes = {
				"html", "css", "scss", "sass", "less",
				"javascript", "javascriptreact", "typescript", "typescriptreact",
				"vue", "svelte", "astro",
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
				-- vim.diagnostic.goto_prev/goto_next are deprecated; jump() takes a
				-- signed count. on_jump() keeps the diagnostic float that
				-- goto_prev/goto_next used to open automatically.
				local diagnostic_jump = function(count)
					return function()
						vim.diagnostic.jump({
							count = count,
							on_jump = function(_, bufnr)
								vim.diagnostic.open_float({
									bufnr = bufnr,
									scope = "cursor",
									focus = false,
								})
							end,
						})
					end
				end
				map("[d", diagnostic_jump(-1), "Prev diagnostic")
				map("]d", diagnostic_jump(1), "Next diagnostic")
				map("<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
				map("<leader>lc", vim.lsp.codelens.run, "Run CodeLens")

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client then
					-- Enable inlay hints for this buffer (if server supports it)
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end
					-- CodeLens (run/test labels above functions)
					-- NOTE: vim.lsp.codelens.refresh() is deprecated on Neovim 0.12+.
					-- enable() starts a per-buffer provider that requests lenses on
					-- attach, re-requests them (debounced) whenever the buffer
					-- changes, and follows workspace/codeLens/refresh pushes from
					-- the server, so the old InsertLeave/BufEnter/CursorHold
					-- refresh autocmds are unnecessary now. enable() only activates
					-- for clients that actually support code lenses.
					vim.lsp.codelens.enable(true, { bufnr = bufnr })
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
		-- NOTE: is_enabled() takes a filter *table*, not a bufnr number.
		vim.keymap.set("n", "<leader>ti", function()
			local bufnr = vim.api.nvim_get_current_buf()
			local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
			vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
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
	-- Auto-install formatters/debuggers that mason-lspconfig does NOT cover
	-- (LSP servers are handled above; without this, conform <leader>cf failed
	-- for js/ts/py/c and JS/Electron DAP had no adapter)
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "mason-org/mason.nvim" },
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"prettier", -- conform: javascript/typescript/html/css/json/yaml/markdown
				"stylua", -- conform: lua
				"ruff", -- conform: python (ruff_format)
				"clang-format", -- conform: c/cpp
				"js-debug-adapter", -- dap: node/chrome/electron/react-native
			},
			auto_update = false,
			run_on_start = false,
		},
	},
}
