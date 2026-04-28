return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = "~/.local/share/db_ui"
    end,
    keys = {
      { "<leader>zo", "<cmd>DBUIToggle<CR>",        desc = "Toggle DB UI" },
      { "<leader>za", "<cmd>DBUIAddConnection<CR>", desc = "Add DB connection" },
      { "<leader>zf", "<cmd>DBUIFindBuffer<CR>",    desc = "Find DB buffer" },
    },
  },
}