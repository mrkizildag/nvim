-- Renders markdown in-buffer: heading backgrounds and icons, code block
-- backgrounds, checkboxes, tables, callouts, quote bars and list bullets.
--
-- Replaces headlines.nvim, which covered only headings/code/rules/quotes and has
-- been frozen since 2024. The two cannot coexist -- `:checkhealth render-markdown`
-- reports headlines.nvim as a hard error.
--
-- nvim-treesitter is listed only because it installs the parsers; the plugin
-- itself calls core `vim.treesitter` and needs no module API, so the `main`
-- branch pinned in treesitter.lua is the supported setup.

return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },

  opts = {
    -- Set explicitly rather than inherited: leaving conceallevel unset has been
    -- reported to break treesitter highlighting after edits near a heading
    -- (render-markdown.nvim#657). These are the plugin's own default values.
    win_options = {
      conceallevel = { default = vim.o.conceallevel, rendered = 3 },
      concealcursor = { default = vim.o.concealcursor, rendered = "" },
    },

    -- Checkbox and callout completion via the plugin's in-process LSP server.
    -- blink.cmp picks this up through its existing `lsp` source, no extra config.
    completions = { lsp = { enabled = true } },

    -- The cursor's line reverts to raw markdown so it stays editable.
    anti_conceal = { enabled = true },

    -- No LaTeX in these notes, and leaving it on makes :checkhealth warn about a
    -- missing `latex` parser plus the utftex/latex2text renderers.
    latex = { enabled = false },

    -- Notes here are mostly flat bullet lists, so the sign column would only
    -- add noise next to every heading and fence.
    heading = { sign = false },
    code = { sign = false, width = "block", right_pad = 2 },
  },
}
