return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
  },
  config = function()
    -- Keymaps on LSP attach
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
      callback = function(event)
        -- Skip Scala files (handled by metals)
        local filetype = vim.bo[event.buf].filetype
        if filetype == 'scala' or filetype == 'sbt' or filetype == 'java' then
          return
        end

        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        local telescope = require('telescope.builtin')

        -- Navigation
        map('gd', telescope.lsp_definitions, '[G]oto [D]efinition')
        map('gr', telescope.lsp_references, '[G]oto [R]eferences')
        map('gi', telescope.lsp_implementations, '[G]oto [I]mplementation')
        map('gt', telescope.lsp_type_definitions, '[G]oto [T]ype Definition')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gO', telescope.lsp_document_symbols, 'Document Symbols')
        map('gW', telescope.lsp_dynamic_workspace_symbols, 'Workspace Symbols')

        -- Actions
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' })

        -- Document highlight
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method('textDocument/documentHighlight') then
          local highlight_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
            callback = function(detach_event)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = detach_event.buf })
            end,
          })
        end

        -- Inlay hints toggle
        if client and client.supports_method('textDocument/inlayHint') then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- UI Configuration
    vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
      border = 'single',
    })

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = {
        source = 'if_many',
        spacing = 2,
      },
    })

    -- LSP Capabilities
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    -- Server configurations
    local servers = {
      pyright = {},
      ts_ls = {},
      hls = {},
      lua_ls = {
        settings = {
          Lua = {
            -- completion = { callSnippet = 'Replace' },
            diagnostics = { globals = { 'vim' } },
          },
        },
      },
    }

    -- Mason setup
    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, { 'stylua' })

    require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

    require('mason-lspconfig').setup({
      ensure_installed = {},
      automatic_installation = false,
      handlers = {
        function(server_name)
          if server_name == 'metals' then
            return -- metals is configured separately
          end

          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    })
  end,
}
