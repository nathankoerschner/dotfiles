vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>pq", ":silent !sqlfluff fix % --dialect snowflake<CR><CR>", { silent = true })
vim.keymap.set("n", "<leader><C-d><C-t><C-f>", ":!rm % <CR> :q<CR>")
-- vim.keymap.set("n", "<leader><C-f>", ":silent !tmux new-window tmux-sessionizer<CR>", { silent = true })
-- vim.keymap.set("n", "<leader><C-d><C-f>", ":!tmux new-window | shv -p '/Users/nathankoerschner/Documents/'<CR>")

