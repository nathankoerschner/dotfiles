return {
	"mason-org/mason.nvim",
	version = "^1.0.0",
	dependencies = {
		{ "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"html",
				"cssls",
				"tailwindcss",
				"svelte",
				"lua_ls",
				"graphql",
				"emmet_ls",
				"marksman",
				"prismals",
				"pyright",
				"ts_ls",
			},
		})

		mason_tool_installer.setup({
			ensure_installed = {
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"ruff", -- python linter
				"eslint_d",
				"sqlfluff",
				"luacheck",
			},
		})
	end,
}
