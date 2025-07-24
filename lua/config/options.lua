--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim.
vim.opt.cmdheight = 1 -- more space in the neovim command line for displaying messages
-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- Force consistent indentation for ALL files
vim.o.expandtab = true -- Always use spaces
vim.o.tabstop = 2 -- Tab display width
vim.o.softtabstop = 2 -- Soft tab width
vim.o.shiftwidth = 2 -- Indent width

vim.o.smartindent = true -- Smart indentation
vim.o.number = true -- Line numbers default
vim.o.relativenumber = true
vim.o.numberwidth = 4

vim.o.ruler = false
vim.o.smoothscroll = true
vim.o.mouse = 'a' -- Enable mouse mode, can be useful for resizing splits for example!
vim.o.showmode = false -- Don't show the mode, since it's already in the status line

vim.opt.laststatus = 3 --disable native statusline

-- Enable break indent
vim.o.breakindent = true
-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true
vim.o.cursorlineopt = 'both'

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 15

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`), instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true
