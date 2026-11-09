-- Match each file's existing indentation (tabs vs spaces, width) on open.
-- Files with no indented lines yet keep the defaults from mrk/set.lua.
return {
  "NMAC427/guess-indent.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
}
