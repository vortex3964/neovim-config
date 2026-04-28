return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        javascript  = { "prettier" },
        typescript  = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        markdown    = { "prettier" },
        go          = { "gofmt" },
        rust        = { "rustfmt" },
        c           = { "clang_format" },
        cpp         = { "clang_format" },
        lua         = { "stylua" },
        python = {"black"},
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    })
  end,
}