return {
  {
    "barrett-ruth/live-server.nvim",
    build = "npm install -g live-server",
    ft = { "html", "css", "javascript", "typescript" },
    keys = {
      { "<leader>ls", "<cmd>LiveServerStart<CR>", desc = "Start live server" },
      { "<leader>lx", "<cmd>LiveServerStop<CR>",  desc = "Stop live server" },
    },
    config = function()
      require("live-server").setup({
        args = { "--port=8080", "--no-browser" }
      })
    end,
  },
}