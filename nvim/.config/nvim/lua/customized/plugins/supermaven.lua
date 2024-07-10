return {
  "supermaven-inc/supermaven-nvim",
  config = function()
    require("supermaven-nvim").setup({
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
      },
      ignore_filetypes = { md = true, markdown = true, csv = true },
      color = {
        suggestion_color = "#ffffff",
        cterm = 244,
      },
      log_level = "off", -- "off", or set to "info" to disable logging 
      disable_inline_completion = false, -- disables inline completion for use with cmp
      disable_keymaps = false, -- disables built in keymaps for more manual control
    })
  end,
}
