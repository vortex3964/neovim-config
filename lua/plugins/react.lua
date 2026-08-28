-- React / React Native / Electron development
-- Keymaps use <leader>w (Web/React) to avoid conflicts
return {
  -- ============================================================
  --  JSX auto-close & auto-rename tags (treesitter-powered)
  -- ============================================================
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
    },
  },

  -- ============================================================
  --  Package.json scripts runner (npm / bun / pnpm / yarn)
  -- ============================================================
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerOpen", "OverseerToggle" },
    keys = {
      { "<leader>wr", "<cmd>OverseerRun<CR>",       desc = "Run npm/bun script" },
      { "<leader>wl", "<cmd>OverseerOpen!<CR>",      desc = "Open task list" },
      { "<leader>wt", "<cmd>OverseerToggle!<CR>",    desc = "Toggle task list" },
    },
    config = function()
      require("overseer").setup({
        templates = { "builtin", "npm" },
        task_list = {
          direction = "bottom",
          max_height = { 15, 0.3 },
          min_height = 5,
          separator = "────────────────────────────────",
          keymaps = {
            ["q"] = { "<CMD>close<CR>", desc = "Close task list" },
            ["<CR>"] = "keymap.run_action",
            ["o"] = "keymap.open",
            ["<C-v>"] = { "keymap.open", opts = { dir = "vsplit" }, desc = "Open in vsplit" },
            ["<C-s>"] = { "keymap.open", opts = { dir = "split" }, desc = "Open in split" },
          },
        },
      })
    end,
  },

  -- ============================================================
  --  Smart import picker (frequency-sorted from your codebase)
  -- ============================================================
  {
    "piersolenski/import.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>wi", function() require("import").pick() end, desc = "Import picker" },
    },
    config = function()
      require("import").setup({ picker = "telescope" })
    end,
  },

  -- ============================================================
  --  Browser & mobile preview via browser-sync
  --  - BrowserPreview:  preview current file with live reload
  --  - BrowserOpen:     open the browser-sync URL
  --  - BrowserSync:     start browser-sync proxy (for localhost)
  --  - BrowserRestart / BrowserStop
  --  Mobile: any device on the same network can connect
  --  Proxy to dev server: BrowserSync start --proxy "http://localhost:3000"
  -- ============================================================
  {
    "ray-x/web-tools.nvim",
    ft = { "html", "css", "javascript", "typescript", "javascriptreact", "typescriptreact" },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    keys = {
      { "<leader>wp", "<cmd>BrowserPreview<CR>",   desc = "Preview in browser (live)" },
      { "<leader>wo", "<cmd>BrowserOpen<CR>",       desc = "Open browser-sync" },
      { "<leader>wR", "<cmd>BrowserRestart<CR>",    desc = "Restart browser-sync" },
      { "<leader>wx", "<cmd>BrowserStop<CR>",       desc = "Stop browser-sync" },
      { "<leader>wP", function()
        local port = vim.fn.input("Dev server port (default 3000): ", "3000")
        if port ~= "" then
          vim.cmd("BrowserSync start --proxy http://localhost:" .. port)
        end
      end, desc = "Proxy to localhost dev server" },
    },
    config = function()
      require("web-tools").setup({
        hue = { enable = true },
      })
    end,
  },

  -- ============================================================
  --  React Native debugging (Hermes attach via DAP)
  -- ============================================================
  {
    "AkisArou/nvim-dap-react-native",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
    },
    config = function()
      local ok, dap_rn = pcall(require, "dap-react-native")
      if not ok then return end

      -- Create the adapter that bridges DAP to React Native DevTools / Hermes CDP
      dap_rn.setup()

      -- Add attach configurations for all JS/TS filetypes
      local dap = require("dap")
      for _, lang in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
        dap.configurations[lang] = dap.configurations[lang] or {}
        table.insert(dap.configurations[lang], {
          type = "reactnativedirect",
          request = "attach",
          name = "React Native: Attach Hermes",
          cwd = "${workspaceFolder}",
        })
      end

      vim.keymap.set("n", "<leader>wd", function()
        dap.continue()
      end, { desc = "Debug React Native (Hermes)" })
    end,
  },
}
