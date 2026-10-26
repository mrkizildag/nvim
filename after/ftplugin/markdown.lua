-- Notes are prose, not code, so soft-wrap them. `wrap` is off globally in
-- lua/mrk/set.lua; these are window-local overrides for markdown buffers only.

vim.opt_local.wrap = true

-- Break at word boundaries instead of mid-word.
vim.opt_local.linebreak = true

-- Keep continuation lines aligned under the indent or list marker they belong to.
vim.opt_local.breakindent = true

-- Continue `- `, `* `, `1. ` and `- [ ] ` lists on Enter; an empty item ends the
-- list. Non-list lines fall through to nvim-autopairs.
vim.keymap.set("i", "<CR>", require("mrk.markdown_list").expr, {
  buffer = true,
  expr = true,
  replace_keycodes = true,
  desc = "Markdown: continue list on newline",
})
