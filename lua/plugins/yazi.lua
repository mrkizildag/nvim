---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  version = "*",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  ---@type YaziConfig | {}
  opts = {
    -- Replaces netrw when opening directories, e.g. `nvim .`
    open_for_directories = true,

    keymaps = {
      show_help = "<f1>",
    },
  },
  init = function()
    -- Disable netrw completely.
    -- Recommended when using open_for_directories = true.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
}
