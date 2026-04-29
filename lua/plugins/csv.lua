-- CSV viewer: async table view for CSV/TSV files
return {
    "hat0uma/csvview.nvim",
    ft = { "csv", "tsv" },
    config = function()
      require("csvview").setup({
        view = {
          display_mode = "border", -- or "highlight"
        },
      })
    end,
    keys = {
      { "<leader>cv", "<cmd>CsvViewToggle<CR>", desc = "Toggle CSV view" },
    },
}