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

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
        keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts)

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
