-- "Run the current file" dispatcher for <leader>rf (wired in mrk/remap.lua).
--
-- Non-Java filetypes go to code_runner.nvim (filetype -> shell command).
--
-- Java is special: a .java file is a build unit, not a standalone script, so
-- plain `javac`/`java` can't resolve its package, generated proto/gRPC sources,
-- or dependency jars. Instead we run the current file's main class through
-- Gradle with the full project classpath, via the `runClass` task added to
-- build.gradle:  ./gradlew runClass -PmainClass=<FQCN>

local M = {}

-- Fully-qualified class name of the current buffer, e.g. "de.tum.foo.Server".
local function current_fqcn()
  local pkg
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, 60, false)) do
    pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
    if pkg then
      break
    end
  end
  local class = vim.fn.expand("%:t:r")
  if pkg then
    return pkg .. "." .. class
  end
  return class
end

-- Directory containing gradlew, searched upward from the current file.
local function gradle_root()
  local start = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
  local found = vim.fs.find({ "gradlew" }, { upward = true, path = start })[1]
  if found then
    return vim.fs.dirname(found)
  end
  return nil
end

local function run_java()
  local root = gradle_root()
  if not root then
    vim.notify("No gradlew found upward from the current file", vim.log.levels.WARN)
    return
  end

  local fqcn = current_fqcn()
  local task = require("overseer").new_task({
    name = "gradle run: " .. fqcn,
    cmd = { root .. "/gradlew" },
    args = { "runClass", "-PmainClass=" .. fqcn },
    cwd = root,
    components = { "default" },
  })
  task:start()
end

-- Run a C# project through the .NET SDK. C# files belong to a project, so
-- prefer the nearest .csproj and let `dotnet run` resolve its dependencies.
local function run_csharp()
  local start = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h")
  local unity_project = vim.fs.find("ProjectSettings", { upward = true, path = start })[1]
  local godot_project = vim.fs.find("project.godot", { upward = true, path = start })[1]

  if unity_project or godot_project then
    vim.notify(
      "C# game projects are launched by their editor; use Unity or Godot to run this project",
      vim.log.levels.INFO
    )
    return
  end

  local project = vim.fs.find(function(name)
    return name:sub(-7) == ".csproj"
  end, { upward = true, path = start })[1]

  if not project then
    vim.notify("No .csproj found upward from the current file", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.dirname(project)
  local task = require("overseer").new_task({
    name = "dotnet run: " .. vim.fn.fnamemodify(project, ":t"),
    cmd = { "dotnet" },
    args = { "run", "--project", project },
    cwd = root,
    components = { "default" },
  })
  task:start()
end

function M.run()
  vim.cmd("silent! write")

  if vim.bo.filetype == "java" then
    run_java()
    return
  end

  if vim.bo.filetype == "cs" then
    run_csharp()
    return
  end

  if vim.fn.exists(":RunFile") == 2 then
    vim.cmd("RunFile")
  else
    vim.notify("code_runner not available for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
  end
end

return M
