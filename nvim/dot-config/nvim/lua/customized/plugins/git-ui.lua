return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      { "<leader>gd", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview git hunk" },
    },
    opts = {},
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      { "echasnovski/mini.icons", opts = {} },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("neo-tree.command").execute({ toggle = true })
          require("neo-tree.git").status_async(vim.uv.cwd(), nil, require("neo-tree").config.git_status_async_options)
        end,
        desc = "Toggle Neo-tree",
      },
    },
    opts = {
      window = {
        width = function()
          return math.max(45, math.floor(vim.o.columns * 0.2))
        end,
        mappings = {
          ["E"] = "expand_all_nodes",
          ["W"] = "close_all_nodes",
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)

      local refresh_git_status = function()
        require("neo-tree.git").status_async(vim.uv.cwd(), nil, require("neo-tree").config.git_status_async_options)
      end

      vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "ShellCmdPost" }, {
        group = vim.api.nvim_create_augroup("UserNeoTreeGitRefresh", { clear = true }),
        callback = refresh_git_status,
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
        group = vim.api.nvim_create_augroup("UserNeoTreeGitRefreshOnTree", { clear = true }),
        callback = function()
          if vim.bo.filetype == "neo-tree" then
            refresh_git_status()
          end
        end,
      })

      for _, group in ipairs({
        "NeoTreeGitAdded",
        "NeoTreeGitModified",
        "NeoTreeGitRenamed",
        "NeoTreeGitStaged",
        "NeoTreeGitUnstaged",
        "NeoTreeGitUntracked",
      }) do
        vim.cmd.highlight({ group, "guifg=#50fa7b", "ctermfg=Green" })
      end
    end,
  },
}
