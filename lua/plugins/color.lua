return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "auto",
        dark_variant = "main",
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
        },

        styles = {
          bold = true,
          transparency = false,
        },

        groups = {
          border = "muted",
          link = "iris",
          panel = "surface",

          error = "love",
          hint = "iris",
          info = "foam",
          note = "pine",
          todo = "rose",
          warn = "gold",

          git_add = "foam",
          git_change = "rose",
          git_delete = "love",
          git_dirty = "rose",
          git_ignore = "muted",
          git_merge = "iris",
          git_rename = "pine",
          git_stage = "iris",
          git_text = "rose",
          git_untracked = "subtle",

          h1 = "iris",
          h2 = "foam",
          h3 = "rose",
          h4 = "gold",
          h5 = "pine",
          h6 = "foam",
        },

        palette = {
          -- Override the builtin palette per variant.
          -- moon = {
          --   base = "#18191a",
          --   overlay = "#363738",
          -- },
        },

        -- Highlight groups are extended (merged) by default.
        highlight_groups = {
          Comment = { fg = "foam" },
          StatusLine = { fg = "love", bg = "love", blend = 15 },
          VertSplit = { fg = "muted", bg = "muted" },
          Visual = { fg = "base", bg = "text", inherit = false },
        },
      })
    end,
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    config = function()
      require("onedarkpro").setup({
        -- OneDark Vivid on the near-black background of stock Neovim (NvimDarkGrey2),
        -- with brighter accents so they still pop on the darker base. Accents sit at
        -- 8-10:1 contrast, below fg (11:1), so no accent outshines plain code.
        colors = {
          onedark_vivid = {
            bg = "#14161b",
            black = "#14161b",
            fg = "#c5cad3",
            red = "#ff859b",
            orange = "#ff9e5e",
            yellow = "#e1bb6d",
            green = "#84ce72",
            cyan = "#2ecdd7",
            blue = "#5cb8ff",
            purple = "#e88cf7",
            comment = "#7a8394",
            cursorline = "#22262f",
            color_column = "#1a1d23",
            selection = "#2b3140",
            float_bg = "#0f1115",
            bg_statusline = "#0f1115",
            line_number = "#4a5161",
            indentline = "#262a33",
            fg_gutter = "#2e333d",
          },
        },
        options = {
          terminal_colors = true,
          cursorline = true,
        },
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon",
        light_style = "day",
        terminal_colors = true,
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "auto",
        background = {
          light = "latte",
          dark = "mocha",
        },
        term_colors = true,
      })
    end,
  },
}
