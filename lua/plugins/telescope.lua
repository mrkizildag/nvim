-- ~/.config/nvim/lua/plugins/telescope.lua

return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",
		},
	},
	opts = {
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	},
	-- The `make` step above was already compiling libfzf.so, but nothing loaded the
	-- extension, so telescope kept using its Lua sorter. load_extension("fzf") is what
	-- swaps in the native one -- without this the dependency is dead weight.
	config = function(_, opts)
		require("telescope").setup(opts)
		require("telescope").load_extension("fzf")
	end,
}
