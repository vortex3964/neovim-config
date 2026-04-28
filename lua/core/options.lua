--relative line numbers and line numbers
vim.opt.number = true
vim.opt.relativenumber = true
vim.cmd("highlight IncSearch guibg=yellow guifg=black")

--how many spaces a tab is
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4

--indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = false

--mouse
vim.opt.mouse = "a"
vim.o.cmdheight = 1 -- more space in the neovim command line for displaying messages

--file --
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.o.conceallevel = 0       -- so that `` is visible in markdown files
vim.o.fileencoding = "utf-8" -- the encoding written to a file

--search
vim.opt.incsearch = true
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "auto"

--for scroling
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8

--random
vim.opt.hlsearch = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.updatetime = 50
vim.opt.showmatch = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.g.editorconfig = true
vim.o.cursorline = false -- highlight the current line

--show mode
vim.o.showmode = false

-- Auto-save when exiting Insert mode
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
  callback = function()
    vim.diagnostic.show()
  end,
})

-- send updates faster
vim.opt.updatetime = 250