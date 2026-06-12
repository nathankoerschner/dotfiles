return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    -- optional: only needed if you actually want nvim-cmp integration
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local keymap = vim.keymap

    -- capabilities: try cmp-nvim-lsp, otherwise fall back to defaults
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if ok then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- default for all servers
    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    -- lua_ls
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          completion = { callSnippet = "Replace" },
        },
      },
    })

    -- emmet_ls
    vim.lsp.config("emmet_ls", {
      filetypes = {
        "html",
        "typescriptreact",
        "javascriptreact",
        "css",
        "sass",
        "scss",
        "less",
        "svelte",
      },
    })

    -- marksman
    vim.lsp.config("marksman", {
      filetypes = { "markdown", "markdown.mdx" },
      root_dir = function(bufnr, on_dir)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(filename, { ".marksman.toml", ".git" })
        if root then
          return on_dir(root)
        end

        -- Personal notes live outside git; give Marksman the whole vault so
        -- wiki links like [[Nils]] can resolve to sibling files such as Nils.md.
        local notes_root = vim.fs.normalize(vim.fn.expand("~/Documents/Documents—SB"))
        local normalized_filename = vim.fs.normalize(filename)
        if normalized_filename == notes_root or vim.startswith(normalized_filename, notes_root .. "/") then
          return on_dir(notes_root)
        end

        -- Fallback keeps Marksman useful for ad-hoc markdown directories.
        on_dir(vim.fs.dirname(filename))
      end,
    })

    -- enable servers (mason-lspconfig installs them, but they need to be enabled)
    vim.lsp.enable("ts_ls")
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("html")
    vim.lsp.enable("cssls")
    vim.lsp.enable("tailwindcss")
    vim.lsp.enable("svelte")
    vim.lsp.enable("graphql")
    vim.lsp.enable("emmet_ls")
    vim.lsp.enable("marksman")
    vim.lsp.enable("prismals")
    vim.lsp.enable("pyright")

    -- show diagnostics inline as virtual text
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underlines = true,
      update_in_insert = false,
      severity_sort = true,
      float = {
        source = true,
      },
    })

    vim.lsp.config("ts_ls", {})

    local function find_wiki_link_under_cursor()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2] + 1
      local search_start = 1

      while true do
        local link_start, link_end, target = line:find("%[%[([^%]]+)%]%]", search_start)
        if not link_start then
          return nil
        end

        if col >= link_start and col <= link_end then
          target = target:gsub("|.*$", ""):gsub("#.*$", "")
          target = vim.trim(target)
          return target ~= "" and target or nil
        end

        search_start = link_end + 1
      end
    end

    local function has_definition(client, bufnr)
      local params = vim.lsp.util.make_position_params(0, client.offset_encoding or "utf-16")
      local response = client:request_sync("textDocument/definition", params, 1000, bufnr)
      local result = response and response.result

      if not result then
        return false
      end

      return result.uri ~= nil or #result > 0
    end

    local function create_missing_marksman_note(client, bufnr)
      local target = find_wiki_link_under_cursor()
      if not target then
        vim.cmd("Telescope lsp_definitions")
        return
      end

      local root = client.config.root_dir or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      local note_path = target:match("%.md$") and target or (target .. ".md")
      local filename = vim.fs.normalize(vim.fs.joinpath(root, note_path))
      local normalized_root = vim.fs.normalize(root)

      if not vim.startswith(filename, normalized_root .. "/") then
        vim.notify("Refusing to create note outside Marksman root: " .. target, vim.log.levels.ERROR)
        return
      end

      vim.fn.mkdir(vim.fs.dirname(filename), "p")
      if vim.fn.filereadable(filename) == 0 then
        vim.fn.writefile({}, filename)
      end

      vim.cmd.edit(vim.fn.fnameescape(filename))
    end

    local function marksman_definition_or_create(bufnr)
      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "marksman" })
      local client = clients[1]

      if not client then
        vim.cmd("Telescope lsp_definitions")
        return
      end

      if has_definition(client, bufnr) then
        vim.cmd("Telescope lsp_definitions")
        return
      end

      create_missing_marksman_note(client, bufnr)
    end

    local function current_note_title(bufnr)
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      for _, line in ipairs(lines) do
        local title = line:match("^#%s+(.+)$")
        if title then
          title = title:gsub("%s+#*$", "")
          return vim.trim(title)
        end
      end

      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t:r")
    end

    local function show_marksman_backlinks_by_title(bufnr)
      local ok_telescope, builtin = pcall(require, "telescope.builtin")
      if not ok_telescope then
        vim.notify("Telescope is required to show note backlinks", vim.log.levels.ERROR)
        return
      end

      local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "marksman" })
      local root = clients[1] and clients[1].config.root_dir or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
      local title = current_note_title(bufnr)

      if not title or title == "" then
        vim.notify("Could not determine current note title", vim.log.levels.WARN)
        return
      end

      builtin.live_grep({
        cwd = root,
        default_text = "[[" .. title,
        prompt_title = "Backlinks to [[" .. title .. "]]",
        additional_args = function()
          -- Treat wiki-link brackets literally instead of as a ripgrep regex.
          return { "--fixed-strings" }
        end,
      })
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Show note backlinks by title"
        keymap.set("n", "<leader>gb", function()
          show_marksman_backlinks_by_title(ev.buf)
        end, opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
        keymap.set("n", "<leader>gd", function()
          marksman_definition_or_create(ev.buf)
        end, opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })
  end,
}
