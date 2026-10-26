-- Per-filetype "run this file" for self-contained files. Invoked by
-- mrk/run.lua via :RunFile.

-- On macOS, C is built and run in the OrbStack 'bash' Linux machine so warnings and
-- behaviour match Linux (same paths are mounted there). Inside Linux it runs directly.
local linux = vim.fn.has("mac") == 1 and "orb -m bash " or ""

return {
  "CRAG666/code_runner.nvim",
  cmd = { "RunCode", "RunFile", "RunProject", "RunClose", "CRFiletype", "CRProjects" },
  opts = {
    mode = "term",
    focus = true,
    startinsert = false,
    term = {
      position = "bot",
      size = 12,
    },
    filetype = {
      python = "python3 -u",
      lua = "lua",
      javascript = "node",
      typescript = { "cd $dir &&", "deno run $fileName" },
      go = "go run",
      rust = { "cd $dir &&", "rustc $fileName -o $fileNameWithoutExt &&", "$dir/$fileNameWithoutExt" },
      c = {
        "cd $dir &&",
        linux .. "gcc -Wall -Wextra -pthread $fileName -o $fileNameWithoutExt &&",
        linux .. "$dir/$fileNameWithoutExt",
      },
      cpp = { "cd $dir &&", "g++ $fileName -o $fileNameWithoutExt &&", "$dir/$fileNameWithoutExt" },
      sh = "bash",
      bash = "bash",
      -- NOTE: no `java` entry on purpose. `javac + java` breaks for packaged
      -- classes; there's no reliable no-build way to run a Java main here.
    },
  },
}
