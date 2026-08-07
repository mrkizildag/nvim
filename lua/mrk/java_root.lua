-- Resolves jdtls's project root for multi-module Gradle/Maven builds.
--
-- The default root detection walks UP from the file and stops at the FIRST dir
-- containing a build marker. In a multi-module build the submodule dir
-- (e.g. InventoryMicroservice/) has its own settings.gradle/build.gradle/gradlew,
-- so jdtls stops there and imports the submodule standalone -> no parent Gradle
-- context, no JRE, "src" mistaken for a package. IntelliJ instead imports from
-- the outermost root (the repo). We reproduce that by walking up to the `.git`
-- boundary and keeping the OUTERMOST dir that still has a build marker.
--
-- Using `.git` itself as the root breaks polyglot monorepos, where the repo root
-- has no build file at all and the Java module sits in a subdirectory (e.g.
-- nemo/scope-api/pom.xml). jdtls then refuses the import and every file comes
-- back as "non-project file, only syntax errors are reported". Bounding the walk
-- by `.git` instead of returning it keeps the multi-module case working (the repo
-- root has settings.gradle, so it is still the outermost marker) while letting a
-- nested module win when the root is not a build root.
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

local function has_build_marker(dir)
  for _, marker in ipairs(BUILD_MARKERS) do
    if vim.uv.fs_stat(dir .. "/" .. marker) then
      return true
    end
  end
  return false
end

-- vim.lsp.config root_dir resolver form: function(bufnr, on_dir).
function M.dir(bufnr, on_dir)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    fname = vim.uv.cwd()
  end

  local git_root = vim.fs.root(fname, ".git")
  local outermost = nil

  local dir = vim.fs.dirname(fname)
  while dir do
    if has_build_marker(dir) then
      outermost = dir
    end
    if dir == git_root then
      break
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end

  on_dir(outermost or git_root or vim.fs.root(fname, BUILD_MARKERS))
end

return M
