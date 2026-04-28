return {
  -- Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 300,
          virt_text_pos = "eol",
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]h", gs.next_hunk,                "Next hunk")
          map("n", "[h", gs.prev_hunk,                "Prev hunk")
          map("n", "<leader>gs", gs.stage_hunk,       "Stage hunk")
          map("n", "<leader>gu", gs.undo_stage_hunk,  "Unstage hunk")
          map("n", "<leader>gr", gs.reset_hunk,       "Reset hunk")
          map("n", "<leader>gS", gs.stage_buffer,     "Stage entire file")
          map("n", "<leader>gR", gs.reset_buffer,     "Reset entire file")
          map("n", "<leader>gp", gs.preview_hunk,     "Preview hunk diff")
          map("n", "<leader>gb", gs.toggle_current_line_blame, "Toggle git blame")
          map("n", "<leader>gd", gs.diffthis,         "Diff current file")
        end,
      })
    end,
  },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "LazyGit",
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Open Lazygit" },
    },
  },

  -- Diffview: side by side diff viewer and merge tool
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles",
      "DiffviewFocusFiles", "DiffviewRefresh", "DiffviewFileHistory",
    },
    keys = {
      { "<leader>gvo", "<cmd>DiffviewOpen<CR>",                desc = "Diffview open" },
      { "<leader>gvc", "<cmd>DiffviewClose<CR>",               desc = "Diffview close" },
      { "<leader>gvh", "<cmd>DiffviewFileHistory %<CR>",       desc = "File history" },
      { "<leader>gvH", "<cmd>DiffviewFileHistory<CR>",         desc = "Repo history" },
      { "<leader>gvm", "<cmd>DiffviewOpen HEAD...MERGE_HEAD<CR>", desc = "View merge conflicts" },
    },
    config = function()
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          merge_tool = {
            layout = "diff3_mixed", -- shows base, ours, theirs and result
            disable_diagnostics = true,
          },
        },
      })
    end,
  },
}