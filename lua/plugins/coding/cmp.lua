local fn = vim.fn

return {
  -- auto completion
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-vsnip" },
    { "hrsh7th/vim-vsnip" }
  },
  opts = function()
    local cmp = require("cmp")
    local conf = {
      sources = {
        { name = "nvim_lsp" },
        { name = "vsnip" },
      },
      snippet = {
        expand = function(args)
          -- Comes from vsnip
          fn["vsnip#anonymous"](args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        -- None of this made sense to me when first looking into this since there
        -- is no vim docs, but you can't have select = true here _unless_ you are
        -- also using the snippet stuff. So keep in mind that if you remove
        -- snippets you need to remove this select
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.confirm({ select = true }),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      })
    }
    return conf
  end
}
