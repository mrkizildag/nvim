-- Project-wide diagnostics list. The existing `gl` / `]d` / `[d` keymaps in
-- lua/mrk/remap.lua are per-line and per-buffer; this is the "show me everything
-- that is broken across the repo" view, which is what a polyglot monorepo needs.
--
-- Deliberately no `symbols` binding: that mode duplicates aerial (lua/plugins/aerial.lua).
return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
  },
  opts = {},
}
