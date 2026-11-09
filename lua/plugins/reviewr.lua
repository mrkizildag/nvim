-- Review a branch or the agent's last turn, comment on lines, and send the comments
-- to the agent beside it. Rex's cmd+r opens it (see ~/.config/rex/init.lua);
-- diffview stays for history and merge conflicts.
return {
  "paul-enz/reviewr.nvim",
  cmd = { "ReviewrOpen", "ReviewrScope", "ReviewrComment", "ReviewrTurn", "ReviewrExport", "ReviewrClear" },
  opts = {},
}
