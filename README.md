# My Neovim Config

A personal Neovim setup built on [lazy.nvim](https://github.com/folke/lazy.nvim), aimed at fast multi-language development with full LSP support, debugging, fuzzy finding, and other good-to-have features.

> Leader key is **Space**. Press `<leader>?` at any time to see every leader-key group (which-key).

## Features

- **Plugin management** via lazy.nvim
- **LSP** through `mason.nvim` + `mason-lspconfig`, with completion powered by `blink.cmp` (styled with a fixed **ayu-dark** palette for the popup/menu windows, on every theme)
- **Debugging** via `nvim-dap` + `nvim-dap-ui`, with adapters auto-installed by `mason-nvim-dap`
- **Formatting on demand** via `conform.nvim` (`<leader>f`)
- **Fuzzy finding** (files, text, buffers, diagnostics) via `telescope.nvim`
- **File explorer** via `neo-tree.nvim`, including image previews (kitty backend)
- **Buffer tabs** via `bufferline.nvim`
- **Statusline** via `lualine.nvim` (diagnostics + custom line/col/wordcount section)
- **Theme switching** via `themery.nvim`, with 11 colorschemes installed (Moonfly is default)
- **Dashboard** via `alpha-nvim` with a dragon header, quick-action buttons and recent files
- **Session persistence** via `persistence.nvim` (works with the dashboard button)
- **TODO/FIX/NOTE comment highlighting** via `todo-comments.nvim`
- **REST client** for `.http` files via `rest.nvim` (requires `curl`, installed on this system)
- **Git everything**: hunks/staging via `gitsigns`, commits/merges/push via `vim-fugitive`, side-by-side diffs + merge tool via `diffview.nvim` — no external binary needed
- **Markdown rendering** in-editor (markview) and in-browser (markdown-preview)
- **Database client** via `vim-dadbod-ui`
- **Quality-of-life editing tools**: autopairs, surround, comment toggling, indent guides, undo tree, Flash jump-to-anywhere motion, symbol outline (Aerial), fuzzy folding (ufo)
- Sane defaults: relative line numbers, persistent undo, system clipboard integration, auto-save on leaving insert mode, and delete/paste operations that don't clobber your yank register

## Language Support

| Language | LSP (mason) | Format (conform) | Debug adapter |
|---|---|---|---|
| JavaScript / TypeScript (JSX/TSX) | `ts_ls`, `eslint` | prettier | pwa-node / pwa-chrome |
| Go | `gopls` | gofmt | delve |
| Rust | `rust-analyzer` | rustfmt | codelldb |
| C / C++ | `clangd` | clang-format | codelldb |
| Python | `basedpyright` (tuned for speed, see below) | ruff_format | — (coming) |
| Lua | `lua_ls` | stylua | — |
| Markdown | `marksman` | prettier | — |
| HTML / CSS / JSON / YAML / SQL / Bash / Docker | `html`, `cssls`, `jsonls`, `yamlls`, `sqlls`, `bashls`, `dockerls` | — | — |

### Python LSP notes (basedpyright)

`basedpyright` replaces pyright and is configured to be fast and quiet:

- `diagnosticMode = "openFilesOnly"` — no full-project scan at startup
- `typeCheckingMode = "basic"` — only real problems, no pedantic type noise
- `autoSearchPaths = false` + `indexing = false` — faster startup

If you still see too many diagnostics, set `typeCheckingMode = "off"` in `plugins/lsp.lua` and rely on your linter. Pick the Python environment with `<leader>pv` (venv-selector auto-selects when only one venv is found).

## Keybinds

### General

| Key | Action |
|---|---|
| `<leader>?` | Show full which-key cheatsheet |
| `<leader>f` | Format file (conform) |
| `<leader>y` | Yank to system clipboard |
| `<leader>d` / `x` / `X` / `D` / `dd` | Delete **without** clobbering the yank register |
| `<Esc>` | Clear search highlight |
| `n` / `N` | Next / prev search result (centered, unfolds) |
| `<C-d>` / `<C-u>` | Half-page scroll, cursor centered |
| `J` / `K` (visual) | Move selected lines down / up |

### Editing

| Key | Action |
|---|---|
| `ys` / `cs` / `ds` | Surround: add / change / delete brackets or quotes |
| `gc` / `gcc` | Toggle comment on selection / line |
| `>t` / `<t` | Jump to next / previous TODO comment |
| `<leader>u` | Toggle undo tree |
| `<C-f>` | Flash: jump to any visible location |
| `<leader>a` | Toggle symbol outline (Aerial) — `{` / `}` navigate symbols there |

### Buffers & Splits

| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>bo` / `<leader>bx` | New buffer / close current buffer |
| `<leader>bf` | Open current buffer in a new tab |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<leader>se` | Make splits equal |
| `<leader>sx` | Close current split |
| `<leader>e` | Focus file explorer on current file |

### Search (Telescope)

| Key | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep in project |
| `<leader>sw` | Grep word under cursor |
| `<leader>sb` | Find open buffers |
| `<leader>sr` | Recent files |
| `<leader>sd` | Search diagnostics |
| `<leader>/` | Fuzzy search in current file |

### LSP

| Key | Action |
|---|---|
| `gd` / `gD` | Go to definition / declaration |
| `gr` / `gi` | Go to references / implementation |
| `K` | Hover docs (rounded border) |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>lf` | Format via LSP |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>ld` | Show diagnostic in floating window |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | `:Git` status window (fugitive) |
| `<leader>gc` | `:Git commit` |
| `<leader>gP` | `:Git push` |
| `<leader>gf` | `:Git pull` |
| `<leader>gm` | `:Git merge` |
| `<leader>gh` / `<leader>gu` | Stage / unstage hunk (gitsigns) |
| `<leader>gr` / `<leader>gR` | Reset hunk / whole buffer |
| `<leader>gS` | Stage entire file |
| `<leader>gp` | Preview hunk diff |
| `<leader>gb` | Toggle blame on current line |
| `<leader>gd` | Diff current file |
| `]h` / `[h` | Next / previous hunk |
| `<leader>gvo` / `<leader>gvc` | Diffview open / close |
| `<leader>gvh` / `<leader>gvH` | File / repo history |
| `<leader>gvm` | Merge conflict tool (diff3 layout) |

**Inside the `:Git` status window**: `s` stage file, `u` unstage, `cc` commit, `ca` amend commit, `du` diff, `dv` vertical diff, `=` toggle inline diff, `gq` close.

### Debugging (DAP) — how to use

1. Open your file and set a breakpoint: `<leader>db`
2. Run: `<leader>dc` (Continue)
3. Step: `<leader>di` (into), `<leader>do` (over), `<leader>dO` (out)
4. `<leader>du` toggles the DAP UI (variables / watches / stack), `<leader>dr` opens the REPL
5. Stop: `<leader>dx` (Terminate)

Adapters are installed automatically: Go (delve), JS/TS (pwa-node), C/C++/Rust (codelldb).

### Sessions

| Key | Action |
|---|---|
| `<leader>qs` | Save the current session |
| `<leader>ql` | Load the last session |
| `<leader>qd` | Stop persisting (clear saved session) |

Dashboard also has a "Restore Session" button (`s`).

### Terminal (toggleterm)

| Key | Action |
|---|---|
| `<C-\>` | Toggle default (floating) terminal |
| `<A-v>` / `<A-h>` / `<A-i>` | Vertical / horizontal / floating terminal |
| `<C-x>` (term mode) | Exit terminal insert mode |

### Databases, Markdown, CSV, PDF, REST, misc

| Key | Action |
|---|---|
| `<leader>zo` / `<leader>za` / `<leader>zf` | Toggle DB UI / add connection / find buffer |
| `<leader>mp` / `<leader>ms` | Markdown preview (browser) open / stop |
| `<leader>cv` | Toggle CSV table view |
| `<leader>po` | Open a PDF |
| `<leader>pj` / `<leader>pk` | PDF next / previous page |
| `<leader>rr` | Run the HTTP request under the cursor (`.http` file) |
| `<leader>rl` | Preview the response |
| `<leader>th` | Theme picker (themery) |
| `<leader>pv` | Select Python venv |
| `<leader>ls` / `<leader>lx` | Live server (HTML/CSS/JS) start / stop |
| `<leader>gsj` / `<leader>gsy` | Go: add json / yaml struct tags |
| `<leader>gsr` | Go: remove json struct tags |
| `<leader>gtf` / `<leader>gta` | Go: test function / generate all tests |
| `<leader>gie` | Go: add `if err` block |
| `<leader>ns` / `<leader>nh` | package.json: show / hide versions |
| `<leader>nu` / `<leader>nd` | package.json: update / delete package |
| `<leader>ni` / `<leader>nv` | package.json: install / change version |
| `<leader>xx` | Trouble: project diagnostics |
| `<leader>xb` | Trouble: buffer diagnostics |
| `<leader>xs` | Trouble: symbols |
| `<leader>xl` | Trouble: LSP definitions |
| `<leader>xq` | Trouble: quickfix list |

## Merge conflict workflow

1. During a merge/rebase you get conflict markers. Open the merge tool: `<leader>gvm`
   (diffview, `diff3_mixed` layout shows base / ours / theirs / result).
2. Stage the resolved hunks with `<leader>gh` (gitsigns) or `:Git add`.
3. Finish the merge: commit with `<leader>gc`, or from `:Git` (`<leader>gg`) press `cc`.
4. Push with `<leader>gP`.

## Other notes

- **Autocomplete colors are always ayu-dark** — blink.cmp re-applies its ayu highlight groups on every `ColorScheme` change, deliberately, so the menu never clashes with the current theme.
- All floating windows (hover, diagnostics, completion, signature help, terminal) use rounded borders.
- Shortcuts worth memorizing: `<TAB>` in blink completion accepts the highlighted item; `<C-space>` force-opens completion.
