return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for debugger
			"nvim-neotest/nvim-nio", -- required by dap-ui
			"williamboman/mason.nvim",
			"jay-babu/mason-nvim-dap.nvim", -- auto installs debug adapters
			"leoluz/nvim-dap-go", -- Go
			"mxsdev/nvim-dap-vscode-js", -- JS/TS
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- mason auto installs adapters
			require("mason-nvim-dap").setup({
				ensure_installed = { "delve", "codelldb", "js-debug-adapter" },
				automatic_installation = true,
			})

			-- Go
			require("dap-go").setup()

			-- JS/TS
			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
				adapters = { "pwa-node", "pwa-chrome" },
			})

			for _, lang in ipairs({ "javascript", "typescript" }) do
				dap.configurations[lang] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
				}
			end

			-- C/C++/Rust via codelldb
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
					args = { "--port", "${port}" },
				},
			}
			for _, lang in ipairs({ "c", "cpp", "rust" }) do
				dap.configurations[lang] = {
					{
						type = "codelldb",
						request = "launch",
						name = "Launch file",
						program = function()
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end,
						cwd = "${workspaceFolder}",
					},
				}
			end

			-- DAP UI auto opens/closes with debugger
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			dapui.setup({ icons = { expanded = "", collapsed = "", current_frame = "" } })

			-- Keymaps
			local map = vim.keymap.set
			map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
			map("n", "<leader>dc", dap.continue, { desc = "Continue" })
			map("n", "<leader>di", dap.step_into, { desc = "Step into" })
			map("n", "<leader>do", dap.step_over, { desc = "Step over" })
			map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
			map("n", "<leader>dr", dap.repl.open, { desc = "Open REPL" })
			map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
			map("n", "<leader>dx", dap.terminate, { desc = "Terminate" })
		end,
	},
}

