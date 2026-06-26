-- Define the function outside of the plugin spec
function ColorMyPencils(color)
  color = color or "angr"
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

  -- Make changed files stand out in Neo-tree. Neo-tree uses different
  -- groups for modified vs. unstaged/untracked status markers.
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
end

-- Return the proper plugin specification
return {
  {
    "phha/zenburn.nvim", -- replace with the actual repository of your colorscheme
    priority = 1000, -- ensure it loads first
    config = function()
      vim.cmd("colorscheme angr")
      ColorMyPencils()
    end,
  },
}
