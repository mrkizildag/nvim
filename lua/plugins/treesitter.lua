return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",

  config = function()
    local ts = require("nvim-treesitter")

    ts.setup({})

    local languages = {
      "bash",
      "c",
      "c_sharp",
      "cpp",
      "css",
      "dockerfile",
      "go",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "php",
      "proto",
      "python",
      "scss",
      "sql",
      "typescript",
      "vim",
      "vue",
      "yaml",
    }

    ts.install(languages)

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local filetype = args.match
        local ok = pcall(vim.treesitter.start)
        if not ok then
          return
        end
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo.foldmethod = "expr"
        vim.wo.foldlevel = 99
        if filetype ~= "cs" then
          pcall(function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end
      end,
    })
  end,
}
