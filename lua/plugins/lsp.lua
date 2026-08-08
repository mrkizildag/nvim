return {
  {
    "j-hui/fidget.nvim",
    opts = {},
  },

  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "mason-org/mason.nvim",
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local function java_home(version)
        local path = vim.fn.trim(vim.fn.system({ "/usr/libexec/java_home", "-v", version }))
        if vim.v.shell_error ~= 0 or path == "" then
          return nil
        end
        return path
      end

      local function execution_environment_name(version)
        if version == "8" then
          return "JavaSE-1.8"
        end
        return "JavaSE-" .. version
      end

      local function normalize_java_version(value)
        if not value or value == "" then
          return nil
        end

        value = value:gsub("_", ".")

        local legacy = value:match("^1%.(%d+)$")
        if legacy then
          return legacy
        end

        local major = value:match("(%d+)")
        return major
      end

      local function read_file(path)
        if vim.fn.filereadable(path) ~= 1 then
          return nil
        end
        return table.concat(vim.fn.readfile(path), "\n")
      end

      local function installed_java_version(path)
        if not path or path == "" then
          return nil
        end

        local release = read_file(path .. "/release")
        if not release then
          return nil
        end

        local java_version = release:match('JAVA_VERSION="([^"]+)"')
        return normalize_java_version(java_version)
      end

      local function detect_installed_jdks()
        local versions = {
          "8",
          "9",
          "10",
          "11",
          "12",
          "13",
          "14",
          "15",
          "16",
          "17",
          "18",
          "19",
          "20",
          "21",
          "22",
          "23",
          "24",
          "25",
          "26",
        }
        local jdks = {}

        for _, version in ipairs(versions) do
          local path = java_home(version)
          if path and installed_java_version(path) == version then
            jdks[version] = path
          end
        end

        return jdks, versions
      end

      local function build_runtimes(installed_jdks, known_versions, default_version)
        local runtimes = {}
        local fallback_default = default_version

        if not fallback_default or not installed_jdks[fallback_default] then
          fallback_default = installed_jdks["21"] and "21" or nil
        end

        if not fallback_default then
          for _, version in ipairs(known_versions) do
            if installed_jdks[version] then
              fallback_default = version
              break
            end
          end
        end

        for _, version in ipairs(known_versions) do
          local path = installed_jdks[version]
          if path then
            table.insert(runtimes, {
              name = execution_environment_name(version),
              path = path,
              default = version == fallback_default or nil,
            })
          end
        end

        return runtimes
      end

      local function detect_project_java_version(root_dir)
        if not root_dir or root_dir == "" then
          return nil
        end

        local java_version_file = root_dir .. "/.java-version"
        if vim.fn.filereadable(java_version_file) == 1 then
          local first_line = vim.fn.readfile(java_version_file, "", 1)[1]
          local version = normalize_java_version(first_line)
          if version then
            return version
          end
        end

        local tool_versions = read_file(root_dir .. "/.tool-versions")
        if tool_versions then
          local toolchain = tool_versions:match("\njava%s+([^\n]+)") or tool_versions:match("^java%s+([^\n]+)")
          local version = normalize_java_version(toolchain)
          if version then
            return version
          end
        end

        local build_files = {
          root_dir .. "/build.gradle",
          root_dir .. "/build.gradle.kts",
          root_dir .. "/pom.xml",
        }
        local patterns = {
          "JavaLanguageVersion%.of%(([%d%.]+)%)",
          "sourceCompatibility%s*=%s*JavaVersion%.VERSION_([%d_]+)",
          "targetCompatibility%s*=%s*JavaVersion%.VERSION_([%d_]+)",
          "sourceCompatibility%s*=%s*['\"]([%d%.]+)['\"]",
          "targetCompatibility%s*=%s*['\"]([%d%.]+)['\"]",
          "options%.release%s*=%s*([%d%.]+)",
          "<maven%.compiler%.release>([%d%.]+)</maven%.compiler%.release>",
          "<maven%.compiler%.source>([%d%.]+)</maven%.compiler%.source>",
          "<java%.version>([%d%.]+)</java%.version>",
        }

        for _, path in ipairs(build_files) do
          local content = read_file(path)
          if content then
            for _, pattern in ipairs(patterns) do
              local version = normalize_java_version(content:match(pattern))
              if version then
                return version
              end
            end
          end
        end

        return nil
      end

      local function join_env_values(values)
        local parts = {}

        for _, value in ipairs(values) do
          if value and value ~= "" then
            table.insert(parts, value)
          end
        end

        return table.concat(parts, " ")
      end

      local function jdtls_cmd(java_executable)
        return function(dispatchers, config)
          local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace"
          local data_dir = workspace_dir

          if config.root_dir then
            data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
          end

          local cmd = { "jdtls" }
          if java_executable then
            table.insert(cmd, "--java-executable")
            table.insert(cmd, java_executable)
          end
          table.insert(cmd, "-data")
          table.insert(cmd, data_dir)

          return vim.lsp.rpc.start(cmd, dispatchers, {
            cwd = config.cmd_cwd,
            env = config.cmd_env,
            detached = config.detached,
          })
        end
      end

      local function ensure_gradle_user_home(path)
        if not path or path == "" then
          return
        end

        vim.fn.mkdir(path, "p")

        local gradle_properties = path .. "/gradle.properties"
        if vim.fn.filereadable(gradle_properties) ~= 1 then
          return
        end

        local kept_lines = {}
        local changed = false
        for _, line in ipairs(vim.fn.readfile(gradle_properties)) do
          if line:match("^org%.gradle%.java%.home=") then
            changed = true
          else
            table.insert(kept_lines, line)
          end
        end

        if changed then
          vim.fn.writefile(kept_lines, gradle_properties)
        end
      end

      local installed_jdks, known_jdk_versions = detect_installed_jdks()
      local jdtls_java_home = installed_jdks["21"]
      local jdtls_java_executable = jdtls_java_home and (jdtls_java_home .. "/bin/java") or nil
      local gradle_user_home = vim.fn.stdpath("config") .. "/gradle-home"

      ensure_gradle_user_home(gradle_user_home)

      local servers = {
        basedpyright = {
          -- Resolve the Python interpreter per project so imports/attributes/signatures
          -- resolve against the right site-packages. Without this, basedpyright falls back
          -- to system python3 and everything third-party becomes "reportMissingImports" +
          -- Unknown types (no completion, no signature help).
          --   1. a project-local .venv/venv (the correct per-project interpreter), else
          --   2. the shared ~/.venvs/eist venv for anything under /uni/EIST (the `eist` alias).
          before_init = function(_, config)
            local root = config.root_dir
            if not root then
              return
            end

            local candidates = {
              root .. "/.venv/bin/python",
              root .. "/venv/bin/python",
            }
            if root:find("/uni/EIST/", 1, true) or root:find("/uni/EIST", 1, true) then
              table.insert(candidates, vim.fn.expand("~/.venvs/eist/bin/python"))
            end

            for _, python_path in ipairs(candidates) do
              if vim.uv.fs_stat(python_path) then
                config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
                  python = { pythonPath = python_path },
                })
                return
              end
            end
          end,
          settings = {
            basedpyright = {
              analysis = {
                -- This repo type-checks with `ty` (see [tool.ty] in backend/pyproject.toml),
                -- which suppresses Optional/argument false-positives basedpyright still flags.
                -- Keep basedpyright for completion/hover/go-to-def; let `ty` own diagnostics.
                -- "off" also silences basedpyright's noisy default reportUnknown*/reportUnannotated*
                -- rules (its default mode is much stricter than plain pyright).
                typeCheckingMode = "off",
              },
            },
          },
        },
        bashls = {},
        -- Route clangd through the OrbStack 'eist' Linux machine so C diagnostics match
        -- Artemis (Linux headers: sem_t is a struct, not int; blocking sem_init; etc.).
        -- Mac files are mounted at identical paths in the machine, so URIs line up.
        -- Revert to `clangd = {}` to use the local macOS clangd again.
        clangd = { cmd = { "orb", "-m", "eist", "clangd", "--background-index" } },
        -- Lint diagnostics for JS/TS. `ts_ls` only reports type errors, so without this
        -- the eslint configs in the repo (frontend/eslint.config.mjs and friends) are
        -- invisible in the editor. Preferred over nvim-lint because it is a real server:
        -- code actions and `:LspEslintFixAll` come with it, and it only attaches in
        -- projects that actually have an eslint config.
        eslint = {},
        gopls = {},
        jdtls = {
          cmd = jdtls_cmd(jdtls_java_executable),
          -- Pin the root to the outermost build (repo root), not the nearest
          -- submodule, so multi-module Gradle projects import as one build.
          root_dir = require("mrk.java_root").dir,
          settings = {
            java = {
              configuration = {
                detectJdksAtStart = true,
                runtimes = build_runtimes(installed_jdks, known_jdk_versions),
              },
              import = {
                gradle = {
                  user = { home = gradle_user_home },
                },
                -- These TUM exercises are dual-rooted (each microservice is both
                -- a Gradle root AND a subproject), which makes Buildship fall back
                -- to a generic import with source=module-root and output=bin/. That
                -- nests output inside source and recurses bin/default/bin/default/...
                -- Excluding bin/ stops the copy explosion so the real Gradle import
                -- (source=src, JRE, deps) takes over. Defaults + our bin/ addition:
                exclusions = {
                  "**/node_modules/**",
                  "**/.metadata/**",
                  "**/archetype-resources/**",
                  "**/META-INF/maven/**",
                  "**/bin/**",
                },
              },
            },
          },
          on_new_config = function(new_config, root_dir)
            local project_java_version = detect_project_java_version(root_dir)
            local project_java_home = project_java_version and installed_jdks[project_java_version] or nil

            if not project_java_home then
              project_java_home = installed_jdks["17"] or vim.env.JAVA_HOME or jdtls_java_home
            end

            local project_runtimes = build_runtimes(installed_jdks, known_jdk_versions, project_java_version)
            local gradle_opts = join_env_values({
              vim.env.GRADLE_OPTS,
              project_java_home and ("-Dorg.gradle.java.home=" .. project_java_home) or nil,
            })

            new_config.cmd_env = vim.tbl_extend("force", new_config.cmd_env or {}, {
              JAVA_HOME = project_java_home,
              GRADLE_USER_HOME = gradle_user_home,
              GRADLE_OPTS = gradle_opts,
            })

            new_config.settings = vim.tbl_deep_extend("force", new_config.settings or {}, {
              java = {
                configuration = {
                  detectJdksAtStart = true,
                  runtimes = project_runtimes,
                },
                import = {
                  gradle = {
                    java = project_java_home and { home = project_java_home } or nil,
                    user = { home = gradle_user_home },
                  },
                },
              },
            })
          end,
        },
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              format = { enable = false },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
                library = vim.api.nvim_get_runtime_file("", true),
              },
            },
          },
        },
        ocamllsp = {},
        protols = {},
        -- Microsoft Roslyn language server: solution-aware C# completion,
        -- diagnostics, refactors, and formatting for .sln/.csproj projects.
        roslyn_ls = {
          cmd_env = {
            DOTNET_ROOT = "/opt/homebrew/opt/dotnet/libexec",
            DOTNET_ROOT_ARM64 = "/opt/homebrew/opt/dotnet/libexec",
          },
        },
        ruff = {
          on_attach = function(client)
            client.server_capabilities.hoverProvider = false
          end,
        },
        ts_ls = {},
        yamlls = {},
      }

      local ensure_installed = vim.tbl_keys(servers)
      vim.list_extend(ensure_installed, {
        "stylua",
        "prettierd",
      })

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
      })

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = false,
      })

      for name in pairs(servers) do
        vim.lsp.enable(name)
      end

      -- `ty` (Astral) is the repo's type checker. Enabled separately from the mason-managed
      -- `servers` table because it's installed as a global uv tool (`uv tool install ty`),
      -- not via mason. Uses nvim-lspconfig's bundled lsp/ty.lua (cmd = { "ty", "server" }),
      -- which auto-discovers each project's [tool.ty] config + .venv via root markers.
      --
      -- ty also advertises definition/references/hover/completion, all of which
      -- basedpyright already answers. Left alone, `gd` returns the same location twice,
      -- `grr` lists every reference twice, and blink shows two identical entries per
      -- symbol. Clear those so the split described above is actually enforced;
      -- diagnostics arrive via publishDiagnostics and are unaffected.
      vim.lsp.config("ty", {
        on_attach = function(client)
          client.server_capabilities.definitionProvider = false
          client.server_capabilities.referencesProvider = false
          client.server_capabilities.hoverProvider = false
          client.server_capabilities.completionProvider = nil
        end,
      })
      vim.lsp.enable("ty")

      -- Neovim >= 0.11 ships with virtual_text off, so diagnostics are otherwise only a
      -- gutter sign + underline and you have to `gl` to read the message.
      vim.diagnostic.config({
        virtual_text = { source = "if_many", spacing = 2 },
        severity_sort = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("mrk-lsp-behavior", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          if client:supports_method("textDocument/documentHighlight", event.buf) then
            local highlight_group = vim.api.nvim_create_augroup("mrk-lsp-highlight", { clear = false })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_group,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("mrk-lsp-detach", { clear = true }),
              callback = function(detach_event)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({
                  group = "mrk-lsp-highlight",
                  buffer = detach_event.buf,
                })
              end,
            })
          end
        end,
      })
    end,
  },
}
