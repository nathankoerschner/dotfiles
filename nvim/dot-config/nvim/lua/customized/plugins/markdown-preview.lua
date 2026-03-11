return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  build = "cd app && npm install --no-package-lock && git checkout -- yarn.lock",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
  end,
}
