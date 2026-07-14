return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      -- Dynamically size the terminal based on direction
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<c-\>]], -- Standard fallback shortcut
      hide_numbers = true,
      shade_terminals = true,
      start_in_insert = true,
      persist_size = true,
      direction = "float", -- Default direction
      float_opts = {
        border = "curved", -- Gives you that clean NvChad look
        winblend = 0,
      },
    })

    -- NvChad-style Keymaps
    local map = vim.keymap.set

    -- Toggle Terminals (Works in Normal and Terminal mode)
    map({"n", "t"}, "<A-v>", "<cmd>ToggleTerm direction=vertical<cr>", { desc = "Toggle vertical terminal" })
    map({"n", "t"}, "<A-h>", "<cmd>ToggleTerm direction=horizontal<cr>", { desc = "Toggle horizontal terminal" })
    map({"n", "t"}, "<A-i>", "<cmd>ToggleTerm direction=float<cr>", { desc = "Toggle floating terminal" })

    -- Easy escape from terminal mode back to normal mode
    map("t", "<C-x>", "<C-\\><C-n>", { desc = "Exit terminal insert mode" })
  end
}
