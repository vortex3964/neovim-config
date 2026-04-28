--language specific languages
return {
  -- =====================
  --          GO
  -- =====================
  {
    "olexsmir/gopher.nvim",
    ft = { "go" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("gopher").setup()

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "go",
        callback = function()
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = true, desc = desc })
          end
          map("<leader>gsj", "<cmd>GoTagAdd json<CR>",  "Add json struct tags")
          map("<leader>gsy", "<cmd>GoTagAdd yaml<CR>",  "Add yaml struct tags")
          map("<leader>gsr", "<cmd>GoTagRm json<CR>",   "Remove struct tags")
          map("<leader>gtf", "<cmd>GoTestFunc<CR>",     "Test function")
          map("<leader>gta", "<cmd>GoTestsAll<CR>",     "Generate all tests")
          map("<leader>gie", "<cmd>GoIfErr<CR>",        "Add if err block")
        end,
      })
    end,
  },

  -- =====================
  --        PYTHON
  -- =====================
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    ft = { "python" },
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("venv-selector").setup({
        auto_select = true, -- auto selects venv if only one found
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          vim.keymap.set("n", "<leader>pv", "<cmd>VenvSelect<CR>",
            { buffer = true, desc = "Select python venv" })
        end,
      })
    end,
  },

  -- =====================
  --       JS / TS
  -- =====================
  {
    "vuki656/package-info.nvim",
    ft = { "json" },
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("package-info").setup({
        colors = {
          up_to_date = "#3C4048",
          outdated   = "#fc514e",
        },
        icons = {
          enable       = true,
          style        = {
            up_to_date = "  ",
            outdated   = "  ",
          },
        },
        autostart         = true,
        hide_up_to_date   = true,  -- only shows outdated packages
        hide_unstable_versions = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "json",
        callback = function()
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = true, silent = true, desc = desc })
          end
          map("<leader>ns",  require("package-info").show,            "Show package versions")
          map("<leader>nh",  require("package-info").hide,            "Hide package versions")
          map("<leader>nu",  require("package-info").update,          "Update package")
          map("<leader>nd",  require("package-info").delete,          "Delete package")
          map("<leader>ni",  require("package-info").install,         "Install new package")
          map("<leader>nv",  require("package-info").change_version,  "Change package version")
        end,
      })
    end,
  },

  -- =====================
  --     ALL LANGUAGES
  -- =====================
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>",                        desc = "Project diagnostics" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",           desc = "Buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>",                desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP definitions" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>",                             desc = "Quickfix list" },
    },
    config = function()
      require("trouble").setup({
        icons = {
          error       = " ",
          warning     = " ",
          hint        = "󰌵 ",
          information = " ",
        },
      })
    end,
  },
}