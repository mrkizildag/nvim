-- Popup listing what can follow a prefix key, once you pause on it.
--
-- Only group labels are declared here. Every individual mapping already passes a `desc`
-- where it is defined (lua/mrk/remap.lua and the `keys` tables in lua/plugins/*), and
-- which-key reads those directly -- repeating them here would be a second copy to keep
-- in sync.
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>r", group = "run / tasks" },
      { "<leader>x", group = "diagnostics" },
      { "<leader>v", group = "review (revu)" },
      { "<leader>y", group = "yazi" },
    },
  },
}
