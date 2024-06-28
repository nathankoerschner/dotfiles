vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
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
vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
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
vim.keymap.set("n", "<leader>da", 'ggdG', { silent = true })
vim.keymap.set("n", "<leader>va", 'ggVG', { silent = true })

vim.keymap.set("n", "<leader>%", ':let @" = expand("%")<CR>p', { silent = true })
-- yank the file path to the clipboard
vim.keymap.set("n", "<leader>yf", function()
    local filename = vim.fn.expand("%:t")
    vim.fn.setreg("+", filename)
end)
