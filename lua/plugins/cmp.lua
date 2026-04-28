return {
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets", -- premade snippets for all languages
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            local body = args.body
            -- Collapse params inside () into a single cursor tabstop
            body = body:gsub("%b()", function(s)
              if s:match("%$") then
                return "(__CUR__)"
              end
              return s
            end)
            -- Strip remaining placeholders
            body = body:gsub("%${%d+:?[^}]*}", ""):gsub("%$%d+", "")
            -- Restore the cursor tabstop inside ()
            body = body:gsub("__CUR__", "$1")
            luasnip.lsp_expand(body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Up>"]   = cmp.mapping.select_prev_item(),
          ["<Down>"] = cmp.mapping.select_next_item(),
          ["<Tab>"]  = cmp.mapping.confirm({ select=true}),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<Esc>"]  = cmp.mapping.abort(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip"  },
          { name = "buffer"   },
          { name = "path"     },
        }),
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = require("lspkind").cmp_format({
          mode          = "symbol_text",
          maxwidth      = 50,
          ellipsis_char = "...",
        menu = {
          nvim_lsp = "[LSP]",
          luasnip  = "[Snip]",
          buffer   = "[Buf]",
          path     = "[Path]",
        },
        }),
      },
      })
    end,
  },
}
