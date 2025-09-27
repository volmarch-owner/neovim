vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.wrap = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.opt.backspace = "indent,eol,start"
vim.opt.clipboard:append("unnamedplus")
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.iskeyword:append("-")
vim.opt.list = true
vim.opt.listchars:append("space:·")
vim.opt.listchars:append("tab:»·")
vim.opt.listchars:append("trail:·")
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle Nvim Tree" })
vim.keymap.set("n", "<leader>h", "<C-w>h", { desc = "Focus Left Window" })
vim.keymap.set("n", "<leader>l", "<C-w>l", { desc = "Focus Right Window" })
local lazy_path = "C:/Users/Ariv/AppData/Local/nvim-data/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazy_path) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazy_path,
	})
end
vim.opt.rtp:prepend(lazy_path)
require("lazy").setup({
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd([[colorscheme tokyonight]])
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				theme = "tokyonight",
				icons_enabled = true,
				section_separators = {
					left = "",
					right = "",
				},
				component_separators = {
					left = "",
					right = "",
				},
				always_divide_middle = true,
				globalstatus = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { "filename" },
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			extensions = { "nvim-tree" },
		},
	},
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			renderer = {
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
					},
				},
			},
			view = {
				width = 30,
				side = "left",
				adaptive_size = true,
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")
			configs.setup({
				auto_install = true,
				ensure_installed = { "lua", "rust" },
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = {
				"lua-language-server",
				"rust-analyzer",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mason_registry = require("mason-registry")
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local pkg = mason_registry.get_package(tool)
					if not pkg:is_installed() then
						pkg:install()
					end
				end
			end
			if mason_registry.refresh then
				mason_registry.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
	{
		"saghen/blink.cmp",
		version = "1.*",
		opts = {
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = { documentation = { auto_show = false } },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			fuzzy = { implementation = "prefer_rust_with_warning" },
		},
		opts_extend = { "sources.default" },
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		opts = {
			servers = {
				lua_ls = {},
			},
		},
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()
			vim.lsp.config.lua_ls = {
				capabilities = capabilities,
				filetypes = { "lua" },
				root_markers = { ".git" },
			}
			vim.lsp.enable({ "lua_ls" })
			vim.lsp.config["rust-analyzer"] = {
				cmd = { "rust-analyzer" },
				filetypes = { "rust" },
				root_markers = { ".git" },
				capabilities = capabilities,
				settings = {
					["rust-analyzer"] = {
						cargo = { allFeatures = true },
						checkOnSave = true,
					},
				},
			}
			vim.lsp.enable({ "rust-analyzer" })
		end,
	},
})
