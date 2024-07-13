return {

  "junegunn/fzf.vim",
  dependencies = {
    "junegunn/fzf",
  },
  config = function()

    vim.keymap.set("n", " A", ':Buffers <CR>')
  end,
}
