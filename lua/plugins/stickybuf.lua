-- Pins special-purpose windows (aerial sidebar, undotree, overseer task list,
-- quickfix, help) to their own buffer kind. Without this, opening a file while
-- focused in one of them loads it into that window -- e.g. a source file rendered
-- in aerial's 30-column sidebar.
--
-- Relevant here because `autojump` in lua/plugins/aerial.lua keeps the cursor in
-- the sidebar while browsing, so file-opening keymaps get pressed from there.
-- Recommended by aerial's own FAQ.
--
-- No configuration: stickybuf's `get_auto_pin` picks the pin type (bufnr/buftype/
-- filetype) per window on its own.
return {
  "stevearc/stickybuf.nvim",
  -- Not lazy: this is a passive guard whose whole job is to already be listening
  -- when a window gets pinned. All it registers is one BufEnter autocmd, so there
  -- is nothing to defer.
  lazy = false,
  opts = {
    -- stickybuf's builtin list covers aerial, OverseerList, fugitive, help and
    -- quickfix, but not undotree -- opening a file from the undotree panel loads it
    -- into that 30-column window. Match undotree's two buffers by name (undotree_N
    -- and diffpanel_N) and pin by bufnr, which is exact. Pinning the `diff`
    -- filetype instead would also catch unrelated diff buffers such as fugitive's.
    get_auto_pin = function(bufnr)
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      if bufname:match("undotree_%d+$") or bufname:match("diffpanel_%d+$") then
        return "bufnr"
      end
      return require("stickybuf").should_auto_pin(bufnr)
    end,
  },
}
