return {
  -- your themes
  { "folke/tokyonight.nvim" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "rose-pine/neovim", name = "rose-pine" },
  { "rebelot/kanagawa.nvim" },
  { "EdenEast/nightfox.nvim" },
  { "Shatur/neovim-ayu", name = "ayu" },
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000, -- loads first before other plugins
  },

  -- theme manager
  {
    "zaldih/themery.nvim",
    config = function()
      require("themery").setup({
        themes = {
          { name = "Moonfly",            colorscheme = "moonfly" },
          { name = "Tokyo Night",        colorscheme = "tokyonight" },
          { name = "Tokyo Night Storm",  colorscheme = "tokyonight-storm" },
          { name = "Tokyo Night Moon",   colorscheme = "tokyonight-moon" },
          { name = "Catppuccin Mocha",   colorscheme = "catppuccin-mocha" },
          { name = "Catppuccin Latte",   colorscheme = "catppuccin-latte" },
          { name = "Rose Pine",          colorscheme = "rose-pine" },
          { name = "Kanagawa",           colorscheme = "kanagawa" },
          { name = "Nightfox",           colorscheme = "nightfox" },
          { name = "Ayu Dark",   colorscheme = "ayu-dark" },
          { name = "Ayu Mirage", colorscheme = "ayu-mirage" },
        },
        livePreview = true,
      })

      vim.keymap.set("n", "<leader>th", "<cmd>Themery<CR>", { desc = "Theme picker" })
    end,
  },
}