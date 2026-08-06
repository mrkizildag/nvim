# nvim

My personal Neovim configuration. Lua, [lazy.nvim](https://github.com/folke/lazy.nvim), native `vim.lsp` config.

## Requirements

- **Neovim >= 0.11** — the LSP setup uses `vim.lsp.config()` / `vim.lsp.enable()`, and
  nvim-treesitter is on the `main` branch (`ts.install()`). Developed on 0.12.
- **git** and **curl** — lazy.nvim bootstraps itself on first launch; mason downloads over HTTPS.
- **make** and a C compiler — builds `telescope-fzf-native`.
- **ripgrep** — telescope `live_grep`. **fd** is optional but speeds up `find_files`.
- **A Nerd Font** — icons in lualine and nvim-web-devicons.

## Install

```bash
git clone git@github.com:mrkizildag/nvim.git ~/.config/nvim
nvim
```

On first launch lazy.nvim clones itself, installs every plugin pinned in
`lazy-lock.json`, and mason installs the language servers listed below. Let it
finish, then restart.

To start from a clean slate first:

```bash
mv ~/.config/nvim{,.bak}
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

## Layout

```
init.lua                 -- require("mrk")
lua/mrk/
  init.lua               -- loads set / lazy / remap, enables persistent undo
  set.lua                -- options
  remap.lua              -- keymaps
  lazy.lua               -- lazy.nvim bootstrap + spec loading
  run.lua                -- :RunFile wrapper around code_runner
  java_root.lua          -- jdtls root resolution for multi-module Gradle/Maven builds
lua/plugins/             -- one file per plugin
lazy-lock.json           -- pinned plugin revisions (committed on purpose)
```

## Language servers

Installed automatically via mason + mason-lspconfig:

`basedpyright` · `bashls` · `clangd` · `gopls` · `jdtls` · `jsonls` · `lua_ls` ·
`ocamllsp` · `protols` · `roslyn_ls` · `ruff` · `ts_ls` · `yamlls`

Formatting is handled by [conform.nvim](https://github.com/stevearc/conform.nvim)
(`stylua` for Lua, installed via mason).

Some servers need a runtime on the host that mason will not install for you:

| Server | Needs |
| --- | --- |
| `jdtls` | JDK 21 on `PATH` or in a standard install location |
| `gopls` | Go toolchain |
| `roslyn_ls` | .NET SDK |
| `ocamllsp` | OCaml / opam switch |
| `ts_ls`, `jsonls`, `yamlls`, `bashls` | Node.js |

`ty` (Astral's Python type checker) is enabled separately from mason and expects a
global install:

```bash
uv tool install ty
```

## Optional integrations

These plugins are configured but only do anything if the external tool is present:

- **[yazi.nvim](https://github.com/mikavilpas/yazi.nvim)** — needs [`yazi`](https://github.com/sxyazi/yazi)
- **[tmux.nvim](https://github.com/aserowy/tmux.nvim)** — pane navigation, needs `tmux`
- **[code_runner.nvim](https://github.com/CRAG666/code_runner.nvim)** — `:RunFile` shells out
  per filetype: `python3`, `node`, `deno`, `go`, `rustc`, `gcc`, `g++`, `bash`. Only the ones
  you actually use need to be installed.

## Machine-specific bits

A few things are wired to my own setup. Change these if you clone this:

- **`clangd`** (`lua/plugins/lsp.lua`) runs inside an [OrbStack](https://orbstack.dev)
  machine — `cmd = { "orb", "-m", "eist", "clangd", ... }`. Replace with plain
  `clangd` unless you have the same VM.
- **`basedpyright`** resolves the interpreter from a project-local `.venv`/`venv`, then
  falls back to `~/.venvs/eist` for paths under `/uni/EIST`. The `.venv` lookup is
  generic; the fallback is not.
- **jdtls Gradle home** is created at `stdpath("config")/gradle-home` (gitignored — it
  grows to a few hundred MB of Gradle cache).

## Themes

Managed by [themery.nvim](https://github.com/zaldih/themery.nvim) — `:Themery` to switch.
Installed: catppuccin, tokyonight, rose-pine, onedarkpro.
