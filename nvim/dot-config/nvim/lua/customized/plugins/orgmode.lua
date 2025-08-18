return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = { "org" },
  config = function()
    require("orgmode").setup({
      org_agenda_files = "~/Documents/*",
      org_default_notes_file = "~/Documents/doc.org",
      win_split_mode = "float",
      org_todo_keywords = { "TODO(t)", "|", "WAITING(w)", "DONE(d)", "CANCELED(c)" },
      org_log_done = false,
      org_adapt_indentation = false,
      org_todo_keyword_faces = {
        WAITING = ":foreground blue :weight bold",
        CANCELED = ":background #FFFFFF :slant italic :underline on",
        TODO = ":background #000000 :foreground red", -- overrides builtin color for `TODO` keyword
      },
    })
  end,
}
