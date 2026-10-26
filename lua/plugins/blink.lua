return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets' },

  -- use a release tag to download pre-built binaries
  version = '1.*',
  -- AND/OR build from source
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source with:
  -- build = 'nix run .#build-plugin',

  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'super-tab',

      -- Stock super-tab, except in markdown, where Tab and S-Tab nest and
      -- un-nest the list item under the cursor the way Notion does. Outside a
      -- list item the handler returns false, which falls through to `fallback`,
      -- i.e. a plain Tab. This lives here rather than in an ftplugin because
      -- blink re-applies its buffer-local keymaps on every InsertEnter.
      ['<Tab>'] = {
        function(cmp)
          if vim.bo.filetype == 'markdown' then
            return require('mrk.markdown_list').indent()
          end
          if cmp.snippet_active() then return cmp.accept() end
          return cmp.select_and_accept()
        end,
        'snippet_forward',
        'fallback',
      },
      ['<S-Tab>'] = {
        function()
          if vim.bo.filetype ~= 'markdown' then return false end
          -- Always consume in markdown: outdenting past the left margin should
          -- do nothing, not fall through to `fallback` and insert whitespace.
          require('mrk.markdown_list').outdent()
          return true
        end,
        'snippet_backward',
        'fallback',
      },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    -- Show the documentation popup automatically shortly after an item is selected.
    completion = { documentation = { auto_show = true, auto_show_delay_ms = 200 } },

    -- Signature help: parameter hints while typing a call (blink has this off by default).
    signature = { enabled = true },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}
