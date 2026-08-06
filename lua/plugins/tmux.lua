return {
  {
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup({
	navigation = {
          enable_default_keybindings = true,
        },
        resize = {
          enable_default_keybindings = true,
        },
        swap = {
          enable_default_keybindings = true,
        },
	})
    end,
  },
}
