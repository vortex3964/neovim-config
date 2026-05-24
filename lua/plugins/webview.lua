return {
  {
    "barrett-ruth/live-server.nvim",
    build = "npm install -g live-server",
    ft = { "html", "css", "javascript", "typescript" },
    keys = {
      { "<leader>ls", "<cmd>LiveServerStart<CR>", desc = "Start live server" },
      { "<leader>lx", "<cmd>LiveServerStop<CR>",  desc = "Stop live server" },
    },
    init = function()
      vim.g.live_server = {
        args = { "--port=8080", "--no-browser" }
      }
    end,
  },
}
