return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    -- On the host (ag-mac; "ag" is its old hostname), nvim runs headless behind Herdr, so open the preview in the
    -- client Mac's browser: serve on all interfaces and hand the URL to `show`.
    if vim.tbl_contains({ "ag-mac", "ag" }, vim.fn.hostname()) and vim.fn.executable("show") == 1 then
      vim.g.mkdp_open_to_the_world = 1
      vim.g.mkdp_open_ip = "ag-mac"
      vim.g.mkdp_echo_preview_url = 1
      vim.cmd([[
        function! MkdpShowOnClient(url) abort
          call jobstart(['show', a:url], {'detach': v:true})
        endfunction
      ]])
      vim.g.mkdp_browserfunc = "MkdpShowOnClient"
    end
  end,
}
