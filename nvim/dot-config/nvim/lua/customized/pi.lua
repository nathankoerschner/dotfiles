local M = {}

local function project_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if vim.v.shell_error == 0 and git_root and git_root ~= "" then
    return git_root
  end
  return vim.fn.getcwd()
end

local function fence_for(path)
  local ft = vim.filetype.match({ filename = path }) or vim.bo.filetype or ""
  return ft
end

local function lines_between(start_line, end_line)
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), start_line, end_line
end

local function selected_lines()
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  return lines_between(start_pos[2], end_pos[2])
end

local function buffer_lines()
  local last = vim.api.nvim_buf_line_count(0)
  return vim.api.nvim_buf_get_lines(0, 0, last, false), 1, last
end

local function open_right_terminal(cmd)
  vim.cmd("botright vertical new")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  local width = math.max(60, math.floor(vim.o.columns * 0.42))
  vim.api.nvim_win_set_width(win, width)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "pi-terminal"
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"

  vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = buf, silent = true })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })

  vim.fn.termopen(cmd, {
    cwd = project_root(),
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "", "[pi exited; press q to close]" })
          end
        end)
      end
    end,
  })
  vim.cmd("startinsert")
end

local function ask_with_context(lines, start_line, end_line)
  local file = vim.fn.expand("%:p")
  local rel_file = vim.fn.fnamemodify(file, ":~:.")
  local root = project_root()

  vim.ui.input({ prompt = "Ask Pi: " }, function(question)
    if not question or question == "" then
      return
    end

    local context = table.concat({
      "I am working from Neovim and want help with this code.",
      "",
      "User request:",
      question,
      "",
      "Context:",
      "- cwd: " .. root,
      "- file: " .. rel_file,
      "- lines: " .. start_line .. "-" .. end_line,
      "",
      "Code:",
      "```" .. fence_for(file),
      table.concat(lines, "\n"),
      "```",
      "",
      "Please use the repository files if you need more context.",
    }, "\n")

    local tmp = vim.fn.tempname() .. ".md"
    vim.fn.writefile(vim.split(context, "\n", { plain = true }), tmp)

    local name = "nvim " .. vim.fn.fnamemodify(file, ":t") .. ":" .. start_line .. "-" .. end_line
    local cmd = "pi --name " .. vim.fn.shellescape(name) .. " @" .. vim.fn.shellescape(tmp)
    open_right_terminal(cmd)
  end)
end

function M.ask_visual()
  local lines, start_line, end_line = selected_lines()
  ask_with_context(lines, start_line, end_line)
end

function M.ask_buffer()
  local lines, start_line, end_line = buffer_lines()
  ask_with_context(lines, start_line, end_line)
end

return M
