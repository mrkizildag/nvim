-- Under tmux, tmux.nvim owns ctrl+hjkl and crosses into tmux panes at nvim's edge.
-- Under Rex (no $TMUX), the same keys cross into Rex panes via `rex focus` instead;
-- Rex's init.lua passes ctrl+hjkl through to nvim, mirroring tmux's is_vim.
local in_rex = vim.env.REX_SESSION ~= nil and vim.env.TMUX == nil

local function rex_navigate(key, direction)
  return function()
    if vim.fn.winnr(key) ~= vim.fn.winnr() then
      vim.cmd.wincmd(key)
    else
      vim.system({ "rex", "focus", direction, "--wrap" })
    end
  end
end

return {
  {
    "aserowy/tmux.nvim",
    config = function()
      require("tmux").setup({
        navigation = {
          enable_default_keybindings = not in_rex,
        },
        resize = {
          enable_default_keybindings = true,
        },
        swap = {
          enable_default_keybindings = true,
        },
      })

      if in_rex then
        vim.keymap.set("n", "<C-h>", rex_navigate("h", "left"), { desc = "Window or Rex pane left" })
        vim.keymap.set("n", "<C-j>", rex_navigate("j", "down"), { desc = "Window or Rex pane down" })
        vim.keymap.set("n", "<C-k>", rex_navigate("k", "up"), { desc = "Window or Rex pane up" })
        vim.keymap.set("n", "<C-l>", rex_navigate("l", "right"), { desc = "Window or Rex pane right" })
      end
    end,
  },
}
