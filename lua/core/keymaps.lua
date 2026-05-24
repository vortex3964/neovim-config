local opts = { noremap = true, silent = true }

vim.g.mapleader = " "

-- in visual mode use J and K to move lines 
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "moves lines down in visual selection" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "moves lines up in visual selection" })

-- the same but for forward and backwards
vim.keymap.set("v", "<", "<gv", opts , { desc = "moves lines back in visual selection" })
vim.keymap.set("v", ">", ">gv", opts , { desc = "moves lines forward in visual selection" })

-- cntrl d and u moves you up and down the buffer
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

-- when searching move to next
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, centered and unfold" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search result, centered and unfold" })

-- the how it be paste
vim.keymap.set("x", "<leader>p", [["_dP]])

-- remember yanked
vim.keymap.set("v", "p", '"_dp', opts)

-- Copies or Yank to system clipboard
vim.keymap.set("n", "<leader>y", [["+Y]], opts)

-- leader d delete wont remember as yanked/clipboard when delete pasting
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

----Open terminal in horizontal split
vim.keymap.set("n", "<leader>ot", ":split | terminal<CR>", { noremap = true, silent = true, desc = "Open terminal" })

-- Close terminal buffer in terminal mode
vim.keymap.set(
	"t",
	"<leader>ct",
	"<C-\\><C-n>:bd!<CR>",
	{ noremap = true, silent = true, desc = "Close terminal buffer" }
)

-- (Optional) Close terminal buffer in normal mode
vim.keymap.set("n", "<leader>ct", ":bd!<CR>", { noremap = true, silent = true, desc = "Close terminal buffer" })

--format
vim.keymap.set("n","<leader>f", function() require("conform").format() end , {desc = "format file"})

--clear highlights
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR><Esc>", { noremap = true, silent = true, desc = "Clear search highlight" })

--quick rename
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word cursor is on globally (a quick rename)" }
)

-- Hightlight yanking when pressing y for example
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({ higroup = "visual", timeout = 500 })
	end,
})

-- tab stuff
-- Tab management redundant we have bufferline
--vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
--vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
--vim.keymap.set("n", "Tab", "<cmd>tabn<CR>", { desc = "Go to next tab" })
--vim.keymap.set("n", "<S-Tab>", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
--vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current file in new tab" })

--split management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
-- split window vertically
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
-- split window horizontally
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
-- close current split window
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

--delete without copying
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }


-- utility binds to stop default behavior
keymap("n", "x", '"_x', opts)
keymap("n", "X", '"_X', opts)
keymap("n", "d", '"_d', opts)
keymap("n", "D", '"_D', opts)
keymap("n", "dd", '"_dd', opts)
keymap("v", "d", '"_d', opts)
keymap("v", "x", '"_x', opts)

