-- Full-window diff / merge / file-history browser.
--
-- Complements gitsigns rather than replacing it: gitsigns draws the in-buffer gutter
-- signs and handles hunks while you edit, diffview is the review surface (branch
-- diffs, per-file history, merge conflict resolution). Diffview has no gutter signs,
-- so both stay.
return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: working tree" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: history (this file)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: history (repo)" },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: close" },
  },
  -- opts as a function so `diffview.actions` is required only once the plugin loads.
  opts = function()
    local actions = require("diffview.actions")

    -- For regular diffs the only valid layouts are diff2_horizontal (the two versions
    -- side by side) and diff2_vertical (stacked). diff1_plain is a single-window view
    -- and is only accepted for merge_tool, so there is no combined/inline layout to
    -- cycle to here. `cycle_layout` therefore just flips the split orientation.
    local toggle = {
      "n",
      "<leader>gt",
      actions.cycle_layout,
      { desc = "Diffview: toggle split layout" },
    }

    return {
      keymaps = {
        -- Registered in all three contexts so the key works whether focus is in the
        -- diff itself, the file list, or the history panel. The plugin's own g<C-x>
        -- stays bound as well.
        view = { toggle },
        file_panel = { toggle },
        file_history_panel = { toggle },
      },
    }
  end,
}
