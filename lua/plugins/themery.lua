return {
  "zaldih/themery.nvim",
  lazy = false,
  config = function()
    require("themery").setup({
      themes = {
        { name = "Rose Pine", colorscheme = "rose-pine" },
        { name = "Rose Pine Main", colorscheme = "rose-pine-main" },
        { name = "Rose Pine Moon", colorscheme = "rose-pine-moon" },
        { name = "Rose Pine Dawn", colorscheme = "rose-pine-dawn" },
        { name = "OneDark", colorscheme = "onedark" },
        { name = "OneLight", colorscheme = "onelight" },
        { name = "OneDark Vivid", colorscheme = "onedark_vivid" },
        { name = "OneDark Dark", colorscheme = "onedark_dark" },
        { name = "Vaporwave", colorscheme = "vaporwave" },
        { name = "Tokyo Night", colorscheme = "tokyonight" },
        { name = "Tokyo Night Storm", colorscheme = "tokyonight-storm" },
        { name = "Tokyo Night Moon", colorscheme = "tokyonight-moon" },
        { name = "Tokyo Night Night", colorscheme = "tokyonight-night" },
        { name = "Tokyo Night Day", colorscheme = "tokyonight-day" },
        { name = "Catppuccin", colorscheme = "catppuccin" },
        { name = "Catppuccin Latte", colorscheme = "catppuccin-latte" },
        { name = "Catppuccin Frappe", colorscheme = "catppuccin-frappe" },
        { name = "Catppuccin Macchiato", colorscheme = "catppuccin-macchiato" },
        { name = "Catppuccin Mocha", colorscheme = "catppuccin-mocha" },
      },
      livePreview = true,
    })
  end,
}
