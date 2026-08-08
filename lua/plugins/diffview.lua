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
  opts = {},
}
