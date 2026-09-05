vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- OPTIONS (only non-defaults)
-- ============================================================================

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "120"
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.showmode = false -- mode is in the statusline
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winborder = "rounded" -- default border for all floating windows (LSP, diagnostics, blink, oil)
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.grepprg = "rg --vimgrep"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.path:append("**") -- `gf` and :find search subfolders
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignorecase = true

-- Files
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true -- persisted under stdpath("state")/undo
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.diffopt:append({ "algorithm:patience", "linematch:60" })

-- Editing
vim.opt.clipboard:append("unnamedplus")
vim.opt.iskeyword:append("-")

-- Performance guards for large files
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
vim.opt.synmaxcol = 300

-- Cursor shape
vim.opt.guicursor = {
  "n-v-c:block",
  "i-ci-ve:ver25",
  "r-cr:hor20",
  "o:hor50",
  "a:blinkwait700-blinkoff400-blinkon250-cursor/lcursor",
  "sm:block-blinkwait175-blinkoff150-blinkon175",
}

-- Folding (treesitter)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- ============================================================================
-- STATUSLINE
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Exposed as a global so the statusline can call it via %{v:lua.Statusline.x()}
Statusline = {}

local cached_branch, last_check = "", 0
function Statusline.git_branch()
  local now = vim.uv.now()
  if now - last_check > 5000 then
    cached_branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
    last_check = now
  end
  if cached_branch == "" then
    return ""
  end
  local branch = #cached_branch > 20 and cached_branch:sub(1, 20) .. "…" or cached_branch
  return " \u{e725} " .. branch .. " "
end

local ft_icons = {
  lua = "\u{e620} ", python = "\u{e73c} ", javascript = "\u{e74e} ", typescript = "\u{e628} ",
  javascriptreact = "\u{e7ba} ", typescriptreact = "\u{e7ba} ", html = "\u{e736} ", css = "\u{e749} ",
  scss = "\u{e749} ", json = "\u{e60b} ", markdown = "\u{e73e} ", vim = "\u{e62b} ", sh = "\u{f489} ",
  bash = "\u{f489} ", zsh = "\u{f489} ", rust = "\u{e7a8} ", go = "\u{e724} ", c = "\u{e61e} ",
  cpp = "\u{e61d} ", java = "\u{e738} ", php = "\u{e73d} ", ruby = "\u{e739} ", swift = "\u{e755} ",
  kotlin = "\u{e634} ", dart = "\u{e798} ", elixir = "\u{e62d} ", haskell = "\u{e777} ", sql = "\u{e706} ",
  yaml = "\u{f481} ", toml = "\u{e615} ", xml = "\u{f05c} ", dockerfile = "\u{f308} ", gitcommit = "\u{f418} ",
  gitconfig = "\u{f1d3} ", vue = "\u{fd42} ", svelte = "\u{e697} ", astro = "\u{e628} ", scala = "\u{e737} ",
}
function Statusline.file_type()
  local ft = vim.bo.filetype
  if ft == "" then
    return " \u{f15b} "
  end
  return (ft_icons[ft] or " \u{f15b} ") .. ft
end

local mode_names = {
  n = " \u{f121}  NORMAL", i = " \u{f11c}  INSERT", v = " \u{f0168} VISUAL", V = " \u{f0168} V-LINE",
  ["\22"] = " \u{f0168} V-BLOCK", c = " \u{f120} COMMAND", s = " \u{f0c5} SELECT", S = " \u{f0c5} S-LINE",
  ["\19"] = " \u{f0c5} S-BLOCK", R = " \u{f044} REPLACE", r = " \u{f044} REPLACE", ["!"] = " \u{f489} SHELL",
  t = " \u{f120} TERMINAL",
}
function Statusline.mode()
  local mode = vim.fn.mode()
  return mode_names[mode] or (" \u{f059} " .. mode)
end

vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  group = augroup,
  callback = function()
    vim.opt_local.statusline = table.concat({
      "  %#StatusLineBold#%{v:lua.Statusline.mode()}%#StatusLine#",
      " \u{e0b1} %f %h%m%r",
      "%{v:lua.Statusline.git_branch()}",
      "\u{e0b1} %{v:lua.Statusline.file_type()}",
      "%=",
      " \u{f017} %l:%c  %P ",
    })
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  group = augroup,
  callback = function()
    vim.opt_local.statusline = "  %f %h%m%r \u{e0b1} %{v:lua.Statusline.file_type()} %=  %l:%c   %P "
  end,
})

-- ============================================================================
-- KEYMAPS
-- ============================================================================
local map = vim.keymap.set

-- Editing
map("x", "p", '"_dP', { desc = "Paste without yanking" })
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Navigation
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Windows
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "_", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "+", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Misc
map("n", "<leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })
map("n", "<leader>r", ":restart<CR>", { desc = "Restart nvim" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

-- Auto-reload files changed outside nvim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = augroup,
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    if vim.o.diff then
      return
    end
    local last_pos = vim.api.nvim_buf_get_mark(0, '"')
    if last_pos[1] >= 1 and last_pos[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
    end
  end,
})

-- Prose: wrap, linebreak, spellcheck
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================
vim.pack.add({
  "https://github.com/rebelot/kanagawa.nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/oil.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },
  -- LSP / completion / debugging
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/mfussenegger/nvim-lint",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/j-hui/fidget.nvim",
  "https://github.com/scalameta/nvim-metals",
  "https://github.com/mfussenegger/nvim-dap",
}, { load = true })

vim.cmd.colorscheme("kanagawa")

-- nvim-treesitter ------------------------------------------------------------
local treesitter = require("nvim-treesitter")
treesitter.setup({})
treesitter.install({ -- skips parsers that are already installed
  "vim", "vimdoc", "lua", "bash", "c", "cpp", "go", "rust", "python",
  "html", "css", "javascript", "typescript", "json", "markdown", "vue", "svelte",
})
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  callback = function(args)
    if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
      vim.treesitter.start(args.buf)
    end
  end,
})

-- oil.nvim -------------------------------------------------------------------
require("oil").setup({
  keymaps = {
    ["<Esc>"] = { "actions.close", mode = "n" },
    ["<CR>"] = "actions.select",
  },
  use_default_keymaps = false,
  float = {
    padding = 10,
    max_width = 200,
    win_options = { signcolumn = "no", winblend = 5 },
  },
  columns = { "icon" },
  view_options = { show_hidden = true },
  preview = {
    max_width = 0.9,
    min_width = { 40, 0.4 },
    max_height = 0.9,
    min_height = { 5, 0.1 },
  },
})
map("n", "-", function() require("oil").open_float() end, { desc = "Open Oil" })

-- fzf-lua --------------------------------------------------------------------
local fzf = require("fzf-lua")
fzf.setup({ oldfiles = { include_current_session = true, cwd_only = true } })
map("n", "<leader>sf", fzf.files, { desc = "Files" })
map("n", "<leader>sg", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>sb", fzf.buffers, { desc = "Buffers" })
map("n", "<leader>sh", function() fzf.help_tags({ query = vim.fn.expand("<cword>") }) end, { desc = "Help tags" })
map("n", "<leader>sd", fzf.diagnostics_document, { desc = "Diagnostics (document)" })
map("n", "<leader>sD", fzf.diagnostics_workspace, { desc = "Diagnostics (workspace)" })
map("n", "<leader>sr", fzf.resume, { desc = "Resume last search" })
map("n", "<leader>s.", fzf.oldfiles, { desc = "Recent files" })
map("n", "<leader>/", fzf.blines, { desc = "Search current buffer" })

-- mini.nvim ------------------------------------------------------------------
require("mini.ai").setup({})
require("mini.comment").setup({})
require("mini.move").setup({})
require("mini.pairs").setup({})
require("mini.splitjoin").setup({ mappings = { toggle = "gs" } })
require("mini.surround").setup({
  mappings = {
    add = "sa", delete = "sd",
    find = "", find_left = "", highlight = "", replace = "", suffix_last = "", suffix_next = "",
  },
})

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = { "n", "v" }, keys = "s" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = { "n", "x" }, keys = "z" },
  },
  clues = {
    { mode = "n", keys = "<leader>s", desc = "+FZF search" },
    miniclue.gen_clues.square_brackets(),
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
  },
  window = { delay = 50 },
})

require("mini.cursorword").setup({ delay = 0 })
require("mini.icons").setup({})
require("mini.trailspace").setup({})
require("mini.indentscope").setup({
  draw = {
    animation = require("mini.indentscope").gen_animation.none(),
    predicate = function(scope)
      if vim.bo.buftype == "terminal" then
        return false
      end
      return not scope.body.is_incomplete
    end,
  },
})

-- gitsigns.nvim --------------------------------------------------------------
require("gitsigns").setup({
  signs = {
    add = { text = "┃" },
    change = { text = "┃" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "┆" },
  },
  current_line_blame = true,
  current_line_blame_opts = { delay = 300 },
})
map("n", "<leader>hd", function() require("gitsigns").diffthis() end, { desc = "Diff this" })

-- fidget.nvim ----------------------------------------------------------------
require("fidget").setup({})

-- ============================================================================
-- DIAGNOSTICS & LSP
-- ============================================================================

vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { source = true, header = "", prefix = "", focusable = false, style = "minimal" },
})

map("n", "<leader>q", function() vim.diagnostic.setloclist({ open = true }) end, { desc = "Diagnostics to loclist" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    local bufnr = ev.buf
    local function bmap(lhs, rhs, desc)
      map("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    bmap("gd", function() fzf.lsp_definitions({ jump1 = true }) end, "Go to definition")
    bmap("gD", vim.lsp.buf.definition, "Go to definition (builtin)")
    bmap("<leader>gS", function()
      vim.cmd("vsplit")
      vim.lsp.buf.definition()
    end, "Go to definition in vsplit")
    bmap("<leader>ca", vim.lsp.buf.code_action, "Code action")
    bmap("<leader>rn", vim.lsp.buf.rename, "Rename")

    bmap("<leader>d", function() vim.diagnostic.open_float({ scope = "cursor" }) end, "Diagnostic under cursor")
    bmap("<leader>D", function() vim.diagnostic.open_float({ scope = "line" }) end, "Diagnostics on line")
    bmap("<leader>nd", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
    bmap("<leader>pd", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")

    bmap("<leader>fr", fzf.lsp_references, "References")
    bmap("<leader>ft", fzf.lsp_typedefs, "Type definitions")
    bmap("<leader>fs", fzf.lsp_document_symbols, "Document symbols")
    bmap("<leader>fw", fzf.lsp_workspace_symbols, "Workspace symbols")
    bmap("<leader>fi", fzf.lsp_implementations, "Implementations")

    if client:supports_method("textDocument/codeAction", bufnr) then
      bmap("<leader>oi", function()
        vim.lsp.buf.code_action({
          context = { only = { "source.organizeImports" }, diagnostics = {} },
          apply = true,
          bufnr = bufnr,
        })
        vim.defer_fn(function()
          require("conform").format({ bufnr = bufnr })
        end, 50)
      end, "Organize imports + format")
    end
  end,
})

-- blink.cmp ------------------------------------------------------------------
require("blink.cmp").setup({
  keymap = {
    preset = "none",
    ["<C-Space>"] = { "show", "hide" },
    ["<CR>"] = { "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "accept", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    menu = {
      auto_show = true,
      draw = {
        components = {
          kind_icon = {
            text = function(ctx)
              return (require("mini.icons").get("lsp", ctx.kind))
            end,
            highlight = function(ctx)
              local _, hl = require("mini.icons").get("lsp", ctx.kind)
              return hl
            end,
          },
        },
      },
    },
    documentation = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text = { enabled = false },
  },
  sources = { default = { "lsp", "path" } },
  fuzzy = { implementation = "prefer_rust", prebuilt_binaries = { download = true } },
})

-- Language servers -----------------------------------------------------------
vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = { globals = { "vim", "Statusline" } },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.enable({ "lua_ls", "pyright", "bashls", "ts_ls", "gopls", "clangd" })

-- ============================================================================
-- FORMATTING (conform.nvim) & LINTING (nvim-lint)
-- ============================================================================
local prettier = { "prettierd" }
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "black" },
    sh = { "shfmt" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    go = { "gofumpt" },
    json = { "fixjson" },
    jsonc = { "fixjson" },
    css = prettier,
    html = prettier,
    markdown = prettier,
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,
    vue = prettier,
    svelte = prettier,
  },
  default_format_opts = { lsp_format = "fallback" }, -- use the LSP when no formatter is listed
})
map({ "n", "v" }, "<leader>cf", function() require("conform").format({ async = true }) end, { desc = "Format" })

local lint = require("lint")
local eslint = { "eslint_d" }
lint.linters_by_ft = {
  lua = { "luacheck" },
  python = { "flake8" },
  sh = { "shellcheck" },
  c = { "cpplint" },
  cpp = { "cpplint" },
  go = { "revive" },
  javascript = eslint,
  javascriptreact = eslint,
  typescript = eslint,
  typescriptreact = eslint,
  vue = eslint,
  svelte = eslint,
}
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
  group = augroup,
  callback = function()
    -- only run linters whose executable is installed, so missing tools stay silent
    local names = vim.tbl_filter(function(name)
      local cmd = lint.linters[name].cmd
      return vim.fn.executable(type(cmd) == "function" and cmd() or cmd) == 1
    end, lint.linters_by_ft[vim.bo.filetype] or {})
    if #names > 0 then
      lint.try_lint(names)
    end
  end,
})

-- ============================================================================
-- SCALA: nvim-metals + nvim-dap
-- ============================================================================
local dap = require("dap")
dap.configurations.scala = {
  { type = "scala", request = "launch", name = "RunOrTest", metals = { runType = "runOrTestFile" } },
  { type = "scala", request = "launch", name = "Test Target", metals = { runType = "testTarget" } },
}
map("n", "<leader>dc", dap.continue, { desc = "DAP Continue" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP Toggle Breakpoint" })
map("n", "<leader>dso", dap.step_over, { desc = "DAP Step Over" })
map("n", "<leader>dsi", dap.step_into, { desc = "DAP Step Into" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP REPL" })

local metals_config = require("metals").bare_config()
metals_config.capabilities = require("blink.cmp").get_lsp_capabilities()
metals_config.capabilities.workspace = { didChangeWatchedFiles = { dynamicRegistration = false } }
metals_config.init_options.statusBarProvider = "off"
metals_config.settings = {
  enableSemanticHighlighting = true,
  showImplicitArguments = true,
  excludedPackages = {},
}
metals_config.on_attach = function()
  require("metals").setup_dap()
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MetalsInitialized",
  once = true,
  callback = function()
    require("metals").import_build()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "scala", "sbt", "java" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
})
