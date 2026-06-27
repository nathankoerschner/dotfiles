local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Some plugins still call the deprecated Neovim 0.11 API. Replace the shim
-- early so those calls go directly to the new API without warning spam.
if vim.lsp.get_clients then
  vim.lsp.get_active_clients = vim.lsp.get_clients
end

require("lazy").setup({ { import = "customized.plugins" }, { import = "customized.plugins.lsp" } }, {
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})
