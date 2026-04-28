return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    {
      "3rd/image.nvim",
      opts = {
        backend = "kitty", -- or "ueberzug" / "ghostty" / "wezterm"
        integrations = {
          neotree = {
            enabled = true,
            clear_on_move = true,
          },
        },
        max_height_window_percentage = 50,
      },
    },
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,

      default_component_configs = {
        indent = {
          indent_size = 2,
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
        },
        -- ICONS RESTORED HERE
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "󰜌",
          default = "󰈚", -- The standard file icon
          highlight = "NeoTreeFileIcon",
        },
        modified = { symbol = "●" },
        git_status = {
          symbols = {
            added     = "",
            modified  = "",
            deleted   = "✖",
            renamed   = "󰁕",
            untracked = "",
            ignored   = "",
            unstaged  = "󰄱",
            staged    = "",
            conflict  = "",
          },
        },
      },

      window = {
        position = "left",
        width = 35,
        mappings = {
          ["<cr>"] = "open",
          ["l"]    = "open",
          ["h"]    = "close_node",
          ["a"]    = "add",
          ["d"]    = "delete",
          ["r"]    = "rename",
          ["y"]    = "copy_to_clipboard",
          ["x"]    = "cut_to_clipboard",
          ["p"]    = "paste_from_clipboard",
          -- Image preview works with this mapping
          ["P"] = { "toggle_preview", config = { use_float = true } },
          ["q"]    = "close_window",
          ["R"]    = "refresh",
          ["?"]    = "show_help",
        },
      },

      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = { "node_modules", "__pycache__", ".venv" },
        },
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_default",
      },
    })

    -- Your custom <leader>e logic
    vim.keymap.set("n", "<leader>e", function()
        local reveal_file = vim.fn.expand("%:p")
        require("neo-tree.command").execute({
            action = "focus",
            reveal_file = reveal_file,
            reveal_force_cwd = true,
        })
    end, { desc = "Focus Neotree" })
  end,
}