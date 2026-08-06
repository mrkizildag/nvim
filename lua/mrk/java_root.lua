-- Resolves jdtls's project root for multi-module Gradle/Maven builds.
--
-- The default root detection walks UP from the file and stops at the FIRST dir
-- containing a build marker. In a multi-module build the submodule dir
-- (e.g. InventoryMicroservice/) has its own settings.gradle/build.gradle/gradlew,
-- so jdtls stops there and imports the submodule standalone -> no parent Gradle
-- context, no JRE, "src" mistaken for a package. IntelliJ instead imports from
-- the outermost root (the repo). We reproduce that by preferring `.git` (present
-- only at the repo root), falling back to the nearest build file for non-git dirs.
--
-- Shared by both Java backends (lua/plugins/lsp.lua native jdtls and
-- lua/plugins/java.lua nvim-java) so root detection is identical either way.

local M = {}

local BUILD_MARKERS = {
  "settings.gradle",
  "settings.gradle.kts",
  "build.gradle",
  "build.gradle.kts",
  "pom.xml",
}

-- vim.lsp.config root_dir resolver form: function(bufnr, on_dir).
function M.dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    fname = vim.uv.cwd()
  end
  local root = vim.fs.root(fname, ".git") or vim.fs.root(fname, BUILD_MARKERS)
  on_dir(root)
end

return M
