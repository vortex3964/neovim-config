return {
  {
    -- GitHub repo is deleted Oct 31, 2026; canonical source is Forgejo.
    url = "https://forge.barrettruth.com/barrettruth/live-server.nvim",
    -- No build step: the server is pure Lua (libuv), zero external deps.
    ft = { "html", "css", "javascript", "typescript" },
    keys = {
      { "<leader>ls", "<cmd>LiveServerStart<CR>", desc = "Start live server" },
      { "<leader>lx", "<cmd>LiveServerStop<CR>",  desc = "Stop live server" },
    },
    init = function()
      vim.g.live_server = {
        port = 8080,
        browser = false,
      }
    end,
  },
}
