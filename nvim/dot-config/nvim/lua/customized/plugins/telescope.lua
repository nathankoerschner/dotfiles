return {
  "nvim-telescope/telescope.nvim",

  tag = "0.1.5",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          n = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },

      pickers = {

        find_files = {

          hidden = true,
        },
      },
    })

    local builtin = require("telescope.builtin")
    -- vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
    vim.keymap.set("n", "<leader>pg", builtin.git_files, {})
    --vim.keymap.set("n", "<leader>ps", function()
    -- builtin.grep_string({ search = vim.fn.input("Grep > ") })
    -- end)
  end,
}
