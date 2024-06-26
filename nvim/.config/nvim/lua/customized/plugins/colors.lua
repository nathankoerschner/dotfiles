-- Define the function outside of the plugin spec
function ColorMyPencils(color)
  color = color or "angr"
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

-- Return the proper plugin specification
return {
  {
    "zacanger/angr.vim", -- replace with the actual repository of your colorscheme
    priority = 1000, -- ensure it loads first
    config = function()
      vim.cmd("colorscheme angr")
      ColorMyPencils()
    end,
  },
}
