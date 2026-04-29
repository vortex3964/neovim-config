-- PDF viewer: open and navigate PDFs inside Neovim
return {
    "basola21/PDFview",
    lazy = false,
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      { "<leader>po", "<cmd>lua require('pdfview').open()<CR>",                           desc = "Open PDF" },
      { "<leader>pj", "<cmd>lua require('pdfview.renderer').next_page()<CR>",             desc = "PDF next page" },
      { "<leader>pk", "<cmd>lua require('pdfview.renderer').previous_page()<CR>",         desc = "PDF prev page" },
    },
    config = function()
      -- auto open PDFs with pdfview when you open a .pdf buffer
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*.pdf",
        callback = function()
          local file_path = vim.api.nvim_buf_get_name(0)
          require("pdfview").open(file_path)
        end,
      })
    end,
}