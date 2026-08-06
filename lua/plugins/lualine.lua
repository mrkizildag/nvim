return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local function theme_for_current_colorscheme()
      if vim.g.colors_name ~= "vaporwave" then
        return "auto"
      end

      local theme = vim.deepcopy(require("lualine.utils.loader").load_theme("vaporwave"))

      theme.normal.a.bg = "#5a8fff"
      theme.normal.b.fg = theme.normal.a.bg

      theme.insert.a.bg = "#7dcfff"
      theme.insert.b.fg = theme.insert.a.bg

      theme.visual.a.bg = "#a858fd"
      theme.visual.b.fg = theme.visual.a.bg

      return theme
    end

    require("lualine").setup({
      options = {
        icons_enabled = true,
        theme = theme_for_current_colorscheme,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        always_show_tabline = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
          refresh_time = 16,
          events = {
            "WinEnter",
            "BufEnter",
            "BufWritePost",
            "SessionLoadPost",
            "FileChangedShellPost",
            "VimResized",
            "Filetype",
            "CursorMoved",
            "CursorMovedI",
            "ModeChanged",
          },
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = {},
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
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
}
