return {
	-- Mason install the LSP server for use
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {
			ensure_installed = {
				"pyright", -- Python
				"clangd", -- C/C++
				--"csharp_ls", -- C#
				"omnisharp",
				"cmake", -- CMake LSP
				"ts_ls", -- TypeScript and JavaScript
				--"asm-lsp", -- ARM Assembly // Is installed directly as a binary package
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"ruff", --Python formatter
				"cmakelang", -- cmake formatter
				"prettier", -- TypeScript and JavaScript Formatter
				"asmfmt", -- Assembler formatter
				"csharpier", -- CSharp formatter
				"taplo",
			},
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = {
			ensure_installed = {
				-- LSP servers
				"pyright",
				"clangd",
				"omnisharp",
				"cmake-language-server",
				"typescript-language-server",
				"taplo",
				"yaml-language-server",
				-- Formatters / Linters
				"ruff",
				"cmakelang",
				"prettier",
				"asmfmt",
				"csharpier",
				-- optional: -- "clang-format",
			},
			run_on_start = true,
		},
	},
	--Schema Store required for yaml
	{
		"b0o/SchemaStore.nvim",
		lazy = true,
		version = false, -- last release is way too old
	},
	-- LSP configuration
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				pyright = {
					pythonPath = "python",
					venvPath = "",
					venv = "",
				},
				clangd = { cmd = { "clangd", "--background-index", "--clang-tidy", "--query-driver=arm-none-eabi-*" } },
				omnisharp = {},
				cmake = {},
				tsserver = {},
				asm_lsp = {
					mason = false,
					cmd = { "$HOME/.local/share/nvim/mason/bin/asm-lsp" },
					filetypes = { "asm", "s", "S" },
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(".git")(fname) or vim.fn.getcwd()
					end,
				},
				taplo = {},
				yamlls = {
					-- Have to add this for yamlls to understand that we support line folding
					capabilities = {
						textDocument = {
							foldingRange = {
								dynamicRegistration = false,
								lineFoldingOnly = true,
							},
						},
					},
					-- lazy-load schemastore when needed
					before_init = function(_, new_config)
						new_config.settings.yaml.schemas = vim.tbl_deep_extend(
							"force",
							new_config.settings.yaml.schemas or {},
							require("schemastore").yaml.schemas()
						)
					end,
					settings = {
						redhat = { telemetry = { enabled = false } },
						yaml = {
							keyOrdering = false,
							format = {
								enable = true,
							},
							validate = true,
							schemaStore = {
								-- Must disable built-in schemaStore support to use
								-- schemas from SchemaStore.nvim plugin
								enable = false,
								-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
								url = "",
							},
						},
					},
				},
			},
		},
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				-- C / C++
				c = { "clang_format" },
				cpp = { "clang_format" },
				-- Python
				python = { "ruff_format" },
				-- C#
				cs = { "csharpier" },
				-- CMake
				cmake = { "cmake_format" },
				-- JavaScript / TypeScript
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				-- ARM Assembly
				asm = { "asmfmt" },
				s = { "asmfmt" },
				S = { "asmfmt" },
				toml = { "taplo" },
			},
			format_on_save = { timeout_ms = 3000, lsp_fallback = true },
		},
	},
}
