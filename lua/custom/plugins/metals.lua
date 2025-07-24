return {
  'scalameta/nvim-metals',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    {
      'mfussenegger/nvim-dap',
      config = function()
        -- DAP setup…
      end,
    },
  },
  ft = { 'scala', 'sbt', 'java' },
  opts = function()
    local metals_config = require('metals').bare_config()

    -- === ADD YOUR INLAY HINTS HERE ===
    metals_config.settings = {
      autoImportBuild = 'all', -- (optional extra setting)
      inlayHints = {
        implicitArguments = { enable = true },
        inferredTypes = { enable = true },
        byNameParameters = { enable = true },
        hintsInPatternMatch = { enable = true },
      },
      -- you can add other settings here too
      fallbackScalaVersion = '3.7.1',

    }

    -- disable Metals’ built-in status messages (we’ll use fidget.nvim)
    metals_config.init_options.statusBarProvider = 'off'

    -- hook in completion capabilities
    metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

    -- Add nvim-cmp capabilities as fallback
    local cmp_capabilities = require('cmp_nvim_lsp').default_capabilities()
    metals_config.capabilities = vim.tbl_deep_extend('force', cmp_capabilities, metals_config.capabilities)

    metals_config.on_attach = function(client, bufnr)
      require('metals').setup_dap()

      -- Print when Metals attaches
      print("Metals attached to buffer " .. bufnr)

      -- Set up keymaps with proper buffer-local scope
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'grn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', 'gra', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'grr', vim.lsp.buf.references, opts)

      -- Force override any existing K mapping
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, noremap = true, silent = true, desc = 'LSP: Show hover documentation' })

      -- SBT integration keymaps
      vim.keymap.set('n', '<leader>mc', '<cmd>MetalsCompileCascade<CR>',
        vim.tbl_extend('force', opts, { desc = 'Metals: Compile cascade' }))
      vim.keymap.set('n', '<leader>mt', '<cmd>MetalsTestClass<CR>',
        vim.tbl_extend('force', opts, { desc = 'Metals: Test class' }))
      vim.keymap.set('n', '<leader>mT', '<cmd>MetalsTestAll<CR>',
        vim.tbl_extend('force', opts, { desc = 'Metals: Test all' }))
    end

    return metals_config
  end,
  config = function(_, metals_config)
    local metals_augroup = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'scala', 'sbt', 'java' },
      callback = function()
        require('metals').initialize_or_attach(metals_config)
      end,
      group = metals_augroup,
    })
  end,
}
