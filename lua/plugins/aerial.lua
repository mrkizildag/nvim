-- Symbol outline sidebar (functions/classes/methods of the current file).
--
-- Backend order is explicit rather than aerial's default: LSP first because it
-- reports signatures and class members that treesitter queries don't, with
-- treesitter as the fallback so the outline still works in buffers where no
-- server is attached (markdown, config files, anything unsupported).
return {
  "stevearc/aerial.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  -- Load on LspAttach, not just on the keys below: `on_attach` (and therefore the
  -- `]f`/`[f` motions) only fires once aerial attaches to the buffer. Lazy-loading
  -- purely on <leader>o would mean the motions silently don't exist until the
  -- sidebar has been opened once in that session.
  event = "LspAttach",
  cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
  keys = {
    { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Toggle symbol outline" },
    { "<leader>O", "<cmd>AerialNavToggle<cr>", desc = "Symbol nav window" },
  },
  opts = {
    backends = { "lsp", "treesitter", "markdown", "man" },

    layout = {
      default_direction = "left",
      min_width = 30,
    },

    show_guides = true,

    -- Move the source window to whatever symbol the cursor is on in the outline,
    -- so j/k in the sidebar browses the file. Focus stays in the aerial window.
    autojump = true,

    -- aerial's own docs suggest `{`/`}` for symbol jumps, but those are the builtin
    -- paragraph motions. Use a dedicated pair instead, matching the `]d`/`[d`
    -- diagnostic keys in lua/mrk/remap.lua.
    on_attach = function(bufnr)
      vim.keymap.set("n", "[f", "<cmd>AerialPrev<cr>", { buffer = bufnr, desc = "Previous symbol" })
      vim.keymap.set("n", "]f", "<cmd>AerialNext<cr>", { buffer = bufnr, desc = "Next symbol" })
    end,
  },
}
