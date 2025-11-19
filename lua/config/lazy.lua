local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    { import = "plugins.lsp" },
    { import = "plugins.editor" },
    { import = "plugins.coding" },
    { import = "plugins.ui" },
    { import = "plugins.git" },
  },
  install = { colorscheme = { "kanagawa" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
