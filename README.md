# My Neovim Config

A personal Neovim setup built on [lazy.nvim](https://github.com/folke/lazy.nvim), aimed at fast multi-language development with full LSP support, debugging, fuzzy finding, and other good-to-have features.

> Leader key is **Space**. Press `<leader>?` at any time to see every leader-key group (which-key).

## Features

- **Plugin management** via lazy.nvim
- **LSP** through `mason.nvim` + `mason-lspconfig`, with completion powered by `blink.cmp` (styled with a fixed **ayu-dark** palette for the popup/menu windows, on every theme) — includes `typescript-tools.nvim` for rich TS/JS support and `pyright` tuned for data science
- **Debugging** via `nvim-dap` + `nvim-dap-ui`, with adapters auto-installed by `mason-nvim-dap`
- **Formatting on demand** via `conform.nvim` (`<leader>cf`)
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

> Inlay hints (types, parameter names) are enabled by default for Go, Rust, Python, TypeScript, C/C++, and Lua. Toggle with `<leader>ti`. CodeLens (run/test labels) is also enabled where supported.

| Language | LSP (mason) | Format (conform) | Debug adapter |
|---|---|---|---|
| JavaScript / TypeScript (JSX/TSX) | `typescript-tools.nvim`, `eslint` | prettier | pwa-node / pwa-chrome |
| Go | `gopls` | gofmt | delve |
| Rust | `rust-analyzer` | rustfmt | codelldb |
| C / C++ | `clangd` | clang-format | codelldb |
| Python | `pyright` (tuned for data science, see below) | ruff_format | — (coming) |
| Lua | `lua_ls` | stylua | — |
| Markdown | `marksman` | prettier | — |
| HTML / CSS / JSON / YAML / SQL / Bash / Docker | `html`, `cssls`, `jsonls`, `yamlls`, `sqlls`, `bashls`, `dockerls`, `tailwindcss`, `emmet_ls` | prettier (html/css/json/yaml) | — |

### Python LSP notes (pyright)

`pyright` is configured for data science / AI / backend work with these key settings:

- `useLibraryCodeForTypes = true` — analyze library code for better completions (critical for numpy, pandas, torch, etc.)
- `autoSearchPaths = true` — find all project files for accurate completions
- `typeCheckingMode = "standard"` — catches real type issues without noise
- `diagnosticMode = "openFilesOnly"` — don't scan entire workspace at startup
- Inlay hints enabled for variable types, return types, parameter types

Pick the Python environment with `<leader>pv` (venv-selector).

## Keybinds

### General

| Key | Action |
|---|---|
| `<leader>?` | Show full which-key cheatsheet |
| `<leader>cf` | Format file (conform) |
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
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep in project |
| `<leader>fw` | Grep word under cursor |
| `<leader>fb` | Find open buffers |
| `<leader>fr` | Recent files |
| `<leader>fd` | Search diagnostics |
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
| `<leader>lc` | Run CodeLens (e.g. run nearest test) |
| `<leader>ti` | Toggle inlay hints (types, param names) |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>ld` | Show diagnostic in floating window |

### Python

| Key | Action |
|---|---|
| `<leader>pv` | Select Python venv (venv-selector) |

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
- **Function completions** insert `foo()` with the cursor between parens (not `foo(int x, int y)`). This is handled by a custom snippet expand function in `plugins/cmp.lua`.
- **Completion deduplication** is enabled for the LSP source to prevent the same item from appearing twice.

## Web Dev Intended Flow

This section explains how to use the React, React Native, and Electron features day-to-day.

### First time setup

1. Install browser-sync globally (needed for live preview on browser and phone):
   ```bash
   npm install -g browser-sync
   ```
2. Restart Neovim. lazy.nvim will install the new plugins automatically.

### React web app

1. Create your app:
   ```bash
   npx create-react-app my-app
   cd my-app
   npm start
   ```
2. Open Neovim in the project folder: `nvim .`
3. Start coding. When you type `<div>` and press `>`, the closing tag `</div>` appears automatically.
4. To see your app live in the browser, press `<leader>wp` (preview). This opens browser-sync.
5. To proxy to your running dev server (e.g. localhost:3000), press `<leader>wP` and enter the port.
6. To run npm scripts without leaving Neovim, press `<leader>wr` and pick a script (dev, build, test, etc.).
7. To add an import, press `<leader>wi` and search for the component or function you want to import.
8. To organize imports, press `<leader>wc`. To add missing imports, press `<leader>wa`.

### React Native app

1. Create your app:
   ```bash
   npx react-native init MyApp
   cd MyApp
   ```
2. Start the Metro bundler: `npx react-native start`
3. Open Neovim in the project folder: `nvim .`
4. To debug on a device or emulator, press `<leader>wd`. This attaches the debugger to the Hermes engine.
5. Set breakpoints with `<leader>db`, then use `<leader>dc` to continue, `<leader>di` to step into, `<leader>do` to step over.
6. To preview on your phone, run the app on a device or emulator. The browser-sync preview works for the web version of React Native as well.

### Electron app

1. Create your app:
   ```bash
   mkdir my-electron-app && cd my-electron-app
   npm init -y
   npm install electron --save-dev
   ```
2. Set up your main.js and renderer files.
3. Open Neovim in the project folder: `nvim .`
4. To debug the main process, press `<leader>dc` and choose "Electron: Main" from the list.
5. To debug the renderer (the browser window), choose "Electron: Renderer".
6. For web-based Electron apps, you can also use "Chrome: Launch" to open and debug in Chrome.

### Live preview on your phone

1. Make sure your computer and phone are on the same Wi-Fi network.
2. In Neovim, press `<leader>wP` and enter your dev server port (e.g. 3000).
3. browser-sync will start and show a URL.
4. Open that URL on your phone. Every time you save a file, the phone browser updates automatically.

### Debugging cheat sheet

| What you want | What to press |
|---|---|
| Set a breakpoint | `<leader>db` |
| Start / continue debugging | `<leader>dc` |
| Step into a function | `<leader>di` |
| Step over a line | `<leader>do` |
| Step out of a function | `<leader>dO` |
| Stop debugging | `<leader>dx` |
| Toggle the debug panel | `<leader>du` |
| Debug React Native (Hermes) | `<leader>wd` |

### npm / bun script runner

| Key | What it does |
|---|---|
| `<leader>wr` | Run a script (shows a list of all scripts in your package.json) |
| `<leader>wl` | Open the task list panel |
| `<leader>wt` | Toggle the task list panel |

### Import helpers

| Key | What it does |
|---|---|
| `<leader>wi` | Open the import picker (searches your codebase for existing imports) |
| `<leader>wc` | Organize imports (sort and remove unused) |
| `<leader>wa` | Add all missing imports automatically |

### Browser preview

| Key | What it does |
|---|---|
| `<leader>wp` | Preview current file in the browser (live reload) |
| `<leader>wo` | Open the browser-sync URL |
| `<leader>wP` | Proxy to a running dev server (e.g. localhost:3000) |
| `<leader>wR` | Restart browser-sync |
| `<leader>wx` | Stop browser-sync |
