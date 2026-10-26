return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- Flat blocks taken from the colorscheme: mode and location on the lightest block,
    -- git and progress on the selection colour, file name on the bar itself. Only the
    -- mode name carries an accent colour.
    local function blocks_theme()
      local function color(group, attr)
        local value = vim.api.nvim_get_hl(0, { name = group, link = false })[attr]
        return value and string.format("#%06x", value) or nil
      end

      local function mix(from, to, amount)
        local a, b = tonumber(from:sub(2), 16), tonumber(to:sub(2), 16)
        local channels = {}
        for shift = 16, 0, -8 do
          local x, y = bit.band(bit.rshift(a, shift), 0xff), bit.band(bit.rshift(b, shift), 0xff)
          table.insert(channels, math.floor(x + (y - x) * amount + 0.5))
        end
        return string.format("#%02x%02x%02x", unpack(channels))
      end

      local fg = color("Normal", "fg")
      local bar = color("StatusLine", "bg") or color("Normal", "bg")
      local block = color("Visual", "bg") or mix(bar, fg, 0.12)
      local mode_block = mix(block, fg, 0.08)
      local muted = color("Comment", "fg")

      local function mode(accent)
        return {
          a = { fg = accent, bg = mode_block, gui = "bold" },
          b = { fg = fg, bg = block },
          c = { fg = fg, bg = bar },
        }
      end

      return {
        normal = mode(color("Function", "fg")),
        insert = mode(color("String", "fg")),
        visual = mode(color("Keyword", "fg")),
        replace = mode(color("DiagnosticError", "fg")),
        command = mode(color("DiagnosticWarn", "fg")),
        inactive = mode(muted),
      }
    end

    local function theme_for_current_colorscheme()
      if vim.g.colors_name ~= "vaporwave" then
        return blocks_theme()
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
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
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
      tabline = {},
      winbar = {},
      inactive_winbar = {},
      extensions = {},
    })
  end,
}
