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

## Keybindings

Leader is `<Space>`. Mode column: **n** normal, **v** visual, **x** visual-block/charwise,
**i** insert. Anything not listed is stock Neovim.

### Editing

| Key | Mode | Action |
| --- | --- | --- |
| `J` | v | Move selection down one line, reindent |
| `K` | v | Move selection up one line, reindent |
| `<C-d>` | n | Half page down, cursor recentered |
| `<C-u>` | n | Half page up, cursor recentered |

### Surround

[nvim-surround](https://github.com/kylechui/nvim-surround). `<char>` is the pair to use —
`"`, `'`, `(`, `[`, `{`, or a tag like `t`.

| Key | Mode | Action |
| --- | --- | --- |
| `ys<motion><char>` | n | Surround the motion — e.g. `ysiw"` wraps a word in quotes |
| `ds<char>` | n | Delete the surrounding pair |
| `cs<old><new>` | n | Change one pair for another |
| `S<char>` | v | Surround the selection |

Opening vs. closing bracket matters: `cs"(` gives `( hello )` with padding, `cs")`
gives `(hello)` without. Visual `S` replaces the builtin linewise-change `S`.

### Paste

Reindent-aware paste from [smart-paste.nvim](https://github.com/nemanjamalesija/smart-paste.nvim) —
same keys as builtin paste, but the pasted text is fitted to the surrounding indentation.

| Key | Mode | Action |
| --- | --- | --- |
| `p` / `P` | n, x | Paste after / before |
| `gp` / `gP` | n | Paste after / before, cursor follows to end of pasted text |
| `]p` / `[p` | n | Paste after / before, charwise text forced onto its own line |

### Find (telescope)

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ff` | n | Find files |
| `<leader>fg` | n | Live grep |
| `<leader>fb` | n | Buffers |
| `<leader>fh` | n | Help tags |
| `<leader>fs` | n | Symbols in current file (aerial picker) |
| `<leader>fS` | n | Symbols across project (LSP, queried live) |

`<leader>fs` uses aerial's telescope extension rather than `lsp_document_symbols` —
it shows the full symbol path and falls back to treesitter, so it works in buffers
with no server. It is current-buffer only, which is why `<leader>fS` stays on
telescope's own workspace picker.

### LSP

Buffer-local — registered on `LspAttach`, so they only exist where a server is running.

| Key | Mode | Action |
| --- | --- | --- |
| `gd` | n | Go to definition |
| `gD` | n | Go to declaration |
| `grr` | n | Find references |
| `gri` | n | Go to implementation |
| `grn` | n | Rename symbol |
| `gra` | n, x | Code action |
| `grt` | n | Go to type definition (Neovim default) |
| `gO` | n | List document symbols in the location list (Neovim default) |
| `K` | n | Hover docs |

`K` is hover in normal mode and "move selection up" in visual mode — different modes,
no conflict.

### Diagnostics

| Key | Mode | Action |
| --- | --- | --- |
| `gl` | n | Show line diagnostics in a float |
| `[d` | n | Previous diagnostic (opens float) |
| `]d` | n | Next diagnostic (opens float) |

[Trouble](https://github.com/folke/trouble.nvim) for the list views — `gl` and `]d`/`[d`
are per-line and per-buffer, these are the whole-project view.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>xx` | n | All diagnostics in the project |
| `<leader>xX` | n | Diagnostics in this buffer only |
| `<leader>xq` | n | Quickfix list |
| `<leader>xl` | n | Location list |

No `symbols` binding on purpose — that Trouble mode duplicates aerial.

### Outline (aerial)

Sidebar of the current file's symbols, docked left. LSP-backed with a treesitter
fallback, so it still populates in buffers with no server attached.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>o` | n | Toggle outline sidebar |
| `<leader>O` | n | Floating symbol nav window |
| `]f` | n | Jump to next symbol |
| `[f` | n | Jump to previous symbol |

`autojump` is on: `<leader>o` puts the cursor in the sidebar, and moving with `j`/`k`
scrolls the source window to each symbol as you pass it. Focus stays in the sidebar.
Use `:AerialToggle!` if you ever want the outline open without taking focus.

`]f` / `[f` rather than aerial's suggested `{` / `}`, which would shadow the builtin
paragraph motions. They work without opening the sidebar first — aerial loads on
`LspAttach`.

### Completion (blink.cmp)

`super-tab` preset — Tab accepts.

| Key | Mode | Action |
| --- | --- | --- |
| `<Tab>` | i | Accept selected item, or jump to next snippet placeholder |
| `<S-Tab>` | i | Jump to previous snippet placeholder |
| `<C-space>` | i | Open menu, then toggle documentation |
| `<C-n>` / `<Down>` | i | Next item |
| `<C-p>` / `<Up>` | i | Previous item |
| `<C-e>` | i | Cancel / hide menu |
| `<C-b>` / `<C-f>` | i | Scroll documentation up / down |
| `<C-k>` | i | Toggle signature help |

### Format

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>F` | n, v | Format buffer via conform (async) |

### Git

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>gs` | n, v | Open fugitive Git panel (`:Git`) |
| `<leader>gd` | n | Diffview: working tree diff |
| `<leader>gh` | n | Diffview: history for this file |
| `<leader>gH` | n | Diffview: history for the repo |
| `<leader>gq` | n | Diffview: close |

Gitsigns is signs-only here (`+ ~ _ ‾`), no keymaps.

[Diffview](https://github.com/sindrets/diffview.nvim) does not replace gitsigns — it has
no gutter signs. Gitsigns marks hunks while you edit; diffview is the review surface for
branch diffs, per-file history, and merge conflicts.

### Files and history

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>ya` | n, v | Open yazi at the current file |
| `<leader>u` | n | Toggle undotree |

### Run and tasks

`<leader>rf` runs a single self-contained file via code_runner; the rest drive overseer.

| Key | Mode | Action |
| --- | --- | --- |
| `<leader>rf` | n | Run current file |
| `<leader>rt` | n | Write buffer, then pick an overseer task |
| `<leader>rr` | n | Restart most recent task |
| `<leader>ro` | n | Toggle task list |
| `<leader>ra` | n | Task action menu |

### tmux panes

Seamless movement between Neovim splits and tmux panes ([tmux.nvim](https://github.com/aserowy/tmux.nvim)).

| Key | Mode | Action |
| --- | --- | --- |
| `<C-h/j/k/l>` | n | Navigate left / down / up / right |
| `<M-h/j/k/l>` | n | Resize pane (Alt) |
| `<C-M-h/j/k/l>` | n | Swap pane (Ctrl+Alt) |

### Themes

No keybinding — run `:Themery` to pick a colorscheme.

## Window behavior

[stickybuf](https://github.com/stevearc/stickybuf.nvim) pins the sidebar windows so a
file opened while focused in one gets redirected to a normal window instead of loading
into a 30-column panel. This matters most with aerial's `autojump`, which leaves the
cursor parked in the outline.

Covered by stickybuf's builtin list: aerial, the overseer task list, fugitive, help and
quickfix. Undotree is **not** in that list, so `lua/plugins/stickybuf.lua` extends
`get_auto_pin` to pin `undotree_N` and `diffpanel_N` by bufnr.

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
