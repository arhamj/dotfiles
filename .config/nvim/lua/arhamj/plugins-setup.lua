-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- { import = "plugins" },
		{ "nvim-lua/plenary.nvim" },
		{ "bluz71/vim-nightfly-colors", name = "nightfly", lazy = false, priority = 1000 },
		{
			"christoomey/vim-tmux-navigator",
			cmd = {
				"TmuxNavigateLeft",
				"TmuxNavigateDown",
				"TmuxNavigateUp",
				"TmuxNavigateRight",
				"TmuxNavigatePrevious",
			},
			keys = {
				{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
				{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
				{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
				{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
				{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
			},
		},
		{ "szw/vim-maximizer" },

		-- essential plugins
		{ "tpope/vim-surround" },
		{ "vim-scripts/ReplaceWithRegister" },

		-- commenting with gc
		{ "numToStr/Comment.nvim" },

		-- file explorer
		{ "nvim-tree/nvim-tree.lua" },

		-- vs-code like icons
		{ "nvim-tree/nvim-web-devicons" },

		-- statusline
		{ "nvim-lualine/lualine.nvim" },

		-- fuzzy finding w/ telescope
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release",
		},
		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-fzf-native.nvim" },
		},

		-- autocompletion
		{ "hrsh7th/nvim-cmp" }, -- completion plugin
		{ "hrsh7th/cmp-buffer" }, -- source for text in buffer
		{ "hrsh7th/cmp-path" }, -- source for file system paths

		-- snippets
		{ "rafamadriz/friendly-snippets" }, -- useful snippets
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
		}, -- snippet engine
		{ "saadparwaiz1/cmp_luasnip" }, -- for autocompletion

		-- managing & installing lsp servers, linters & formatters
		{ "williamboman/mason.nvim" }, -- in charge of managing lsp servers, linters & formatters
		{ "williamboman/mason-lspconfig.nvim" }, -- bridges gap b/w mason & lspconfig

		-- configuring lsp servers
		{ "neovim/nvim-lspconfig" }, -- easily configure language servers
		{ "hrsh7th/cmp-nvim-lsp" }, -- for autocompletion
		{
			"glepnir/lspsaga.nvim",
			branch = "main",
			requires = {
				{ "nvim-tree/nvim-web-devicons" },
				{ "nvim-treesitter/nvim-treesitter" },
			},
		}, -- enhanced lsp uis
		{ "onsails/lspkind.nvim" }, -- vs-code like icons for autocompletion

		-- formatting & linting
		{ "jose-elias-alvarez/null-ls.nvim" }, -- configure formatters & linters
		{ "jayp0521/mason-null-ls.nvim" }, -- bridges gap b/w mason & null-ls

		-- treesitter configuration
		{ { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" } },

		-- auto closing
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},
		{ "windwp/nvim-ts-autotag", after = "nvim-treesitter" },

		-- git integration
		{ "lewis6991/gitsigns.nvim" },
	},

	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "nightfly" } },
	-- automatically check for plugin updates
	checker = { enabled = true },
})
