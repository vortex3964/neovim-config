# My Neovim Config

A personal Neovim setup built on [lazy.nvim](https://github.com/folke/lazy.nvim), aimed at fast multi-language development with full LSP support, debugging, fuzzy finding, and other good to have features.

## Features

- **Plugin management** via lazy.nvim
- **LSP** through `mason.nvim` + `mason-lspconfig`, with completion powered by `blink.cmp`
- **Debugging** via `nvim-dap` + `nvim-dap-ui`, with adapters auto-installed by `mason-nvim-dap`
- **Formatting on save/demand** via `conform.nvim`
- **Fuzzy finding** (files, text, buffers, diagnostics) via `telescope.nvim`
- **File explorer** via `neo-tree.nvim`, including image previews
- **Buffer tabs** via `bufferline.nvim`
- **Statusline** via `lualine.nvim`, with word count / reading time shown for prose (Markdown/text) files
- **Theme switching** via `themery.nvim`, with 11 colorschemes installed (Moonfly is default)
- **Dashboard** via `alpha-nvim` with quick-action buttons and recent files
- **TODO/FIX/NOTE comment highlighting** via `todo-comments.nvim`
- **Markdown rendering** in-editor and in-browser
- **Database client** via `vim-dadbod-ui`
- **Quality-of-life editing tools**: autopairs, surround, comment toggling, indent guides, undo tree, Flash jump-to-anywhere motion, symbol outline (Aerial), and inline function signature hints
- Sane defaults out of the box: relative line numbers, persistent undo, system clipboard integration, auto-save on leaving insert mode, and delete/paste operations that don't clobber your yank register
- Also wired up (via `plugins.git`, `plugins.folding`, `plugins.webview`, `plugins.cmp`, `plugins.csv`, `plugins.pdf`): Git integration, code folding, an in-editor webview, autocompletion, and CSV/PDF viewing

## Language Support

**JavaScript / TypeScript (incl. JSX/TSX)** — Full Treesitter highlighting/indent, LSP via `ts_ls`, formatting via Prettier, and debugging via `nvim-dap-vscode-js` (pwa-node/pwa-chrome adapters).

**Go** — Treesitter highlighting, LSP via `gopls`, formatting via `gofmt`, and dedicated debugging support through `nvim-dap-go`.

**Rust** — Treesitter highlighting, LSP via `rust_analyzer`, formatting via `rustfmt`, and debugging through the `codelldb` adapter.

**C / C++** — Treesitter highlighting, LSP via `clangd`, formatting via `clang-format`, and debugging through `codelldb`.

**Python** — Treesitter highlighting, LSP via `pyright`, and formatting via `black`. (No debug adapter configured yet.)

**Lua** — Treesitter highlighting and formatting via `stylua`. This is also the language the config itself is written in.

**Markdown** — Treesitter highlighting, LSP via `marksman`, Prettier formatting, plus in-editor rendering (`markview.nvim`) and a live browser preview (`markdown-preview.nvim`).

**SQL** — Not covered by Treesitter/LSP in this config, but fully supported for querying and browsing through `vim-dadbod-ui` with SQL completion.

## Other Notable Features

- **which-key.nvim** shows a full cheatsheet of every leader-key group as you type — press `<leader>?` any time for the complete list
- **Highlight-on-yank** flashes whatever text you just copied
- **Auto-centering** on scroll and search so your cursor never gets lost near screen edges
- **Custom quick-rename**: rename every occurrence of the word under your cursor in one keystroke
- **Word-aware statusline** for prose files (Markdown/text): live word count and estimated reading time

## Keybinds

Leader key is **Space**.

### General
| Key | Action |
|---|---|
| `<leader>?` | Show full which-key cheatsheet |
| `<leader>f` | Format current file |
| `<leader>s` | Rename word under cursor (project-wide, current buffer) |
| `<Esc>` | Clear search highlight |
| `<leader>y` | Yank to system clipboard |
| `<leader>d` | Delete without overwriting clipboard/register |
| `<leader>u` | Toggle undo tree |
| `<leader>th` | Open theme picker |
| `<leader>a` | Toggle symbol outline (Aerial) |
| `<C-f>` | Flash jump to any visible location |

### Buffers & Splits
| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | Next / previous buffer |
| `<leader>bo` | Open new buffer |
| `<leader>bx` | Close current buffer |
| `<leader>sv` / `<leader>sh` | Split vertically / horizontally |
| `<leader>sx` | Close current split |
| `<leader>e` | Focus file explorer (Neo-tree) on current file |

### Search (Telescope)
| Key | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep in project |
| `<leader>sw` | Grep word under cursor |
| `<leader>sb` | Find open buffers |
| `<leader>sr` | Recent files |
| `<leader>/` | Fuzzy search in current file |

### LSP
| Key | Action |
|---|---|
| `gd` / `gD` | Go to definition / declaration |
| `gr` / `gi` | Go to references / implementation |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Previous / next diagnostic |

### Debugging (DAP)
| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / over / out |
| `<leader>du` | Toggle DAP UI |
| `<leader>dx` | Terminate session |

### Database & Markdown
| Key | Action |
|---|---|
| `<leader>zo` | Toggle DB UI |
| `<leader>za` | Add DB connection |
| `<leader>mp` | Open Markdown preview (browser) |
| `<leader>ms` | Stop Markdown preview |
