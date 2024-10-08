return {
  "tpope/vim-fugitive",
  dependencies = {
    "tpope/vim-rhubarb",
  },
  config = function()
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
  end,
}
