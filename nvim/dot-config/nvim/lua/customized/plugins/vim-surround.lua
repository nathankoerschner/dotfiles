return {
  "tpope/vim-surround",
  config = function()
    vim.keymap.set("n", "<leader>s", [["ds'"]], { silent = true })
  end,
}
