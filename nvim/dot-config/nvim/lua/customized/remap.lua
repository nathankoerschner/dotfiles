vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>pi", function()
  require("customized.pi").ask_buffer()
end, { desc = "Ask Pi about current buffer" })
vim.keymap.set("v", "<leader>pi", function()
  require("customized.pi").ask_visual()
end, { desc = "Ask Pi about selection" })
vim.keymap.set("n", "<leader>pq", ":silent !sqlfluff fix % --dialect snowflake<CR><CR>", { silent = true })
vim.keymap.set("n", "<leader><C-d><C-t><C-f>", ":!rm % <CR> :q<CR>")
vim.keymap.set("n", "<leader><C-f>", ":silent !tmux new-window tmux-sessionizer<CR>", { silent = true })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Remaps to skip yanking of text in common scenarios
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("n", "Q", "<nop>") -- disable ex mode

-- start renaming selected word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)

-- remaps to do common operations on all text in buffer
vim.keymap.set("n", "<leader>ya", 'm9ggvG"+YG`9:delm9<CR>', { silent = true })
vim.keymap.set("n", "<leader>da", "ggdG", { silent = true })
vim.keymap.set("n", "<leader>va", "ggVG", { silent = true })

vim.keymap.set("n", "<leader>%", ':let @" = expand("%")<CR>p', { silent = true })
-- yank the full file path to the clipboard
-- In oil buffers, yank the directory the buffer is showing.
vim.keymap.set("n", "<leader>yf", function()
  local filepath
  if vim.bo.filetype == "oil" then
    local ok, oil = pcall(require, "oil")
    if ok then
      filepath = oil.get_current_dir()
    end
  end
  if not filepath or filepath == "" then
    filepath = vim.fn.expand("%:p")
  end
  vim.fn.setreg("+", filepath)
  vim.notify("Yanked: " .. filepath)
end)

vim.keymap.set("v", "<leader>z", 'c{{c1::<C-r>"}}<ESC>F{ll')

-- Remaps for fzf
-- <leader>pf searches all files; <leader>pg stays limited to git files
vim.keymap.set("n", "<leader>pf", ":Files<CR>")
vim.keymap.set("n", "<leader>pg", ":GFiles<CR>")
vim.keymap.set("n", "<leader>ps", ":RG<CR>")
vim.keymap.set("n", "<leader>b", ":Buffers <CR>")
vim.keymap.set("n", "<leader>l", ":BLines<CR>")
