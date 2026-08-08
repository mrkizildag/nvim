-- Add/change/delete surrounding pairs: ys<motion><char>, ds<char>, cs<old><new>,
-- and S<char> on a visual selection.
--
-- Note: this takes visual-mode `S`, which builtin-wise is a linewise change (same
-- as `V c`). That is nvim-surround's default and the usual trade.
return {
  "kylechui/nvim-surround",
  version = "*",
  event = { "BufReadPre", "BufNewFile" },
  opts = {},
}
