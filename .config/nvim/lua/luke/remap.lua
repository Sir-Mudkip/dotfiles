-- vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
 
-- move highlighted text
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
 
-- move line to end
vim.keymap.set("n", "J", "mzJ`z")
 
-- keep cursor in the middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
 
vim.keymap.set("x", "<leader>p", [["_dP]])
 
vim.keymap.set("i", "<C-c>", "<Esc>")
 
vim.keymap.set("n", "Q", "<nop>")
 
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)
 
-- keep text highlighted when indenting
vim.keymap.set("x", "<", "<gv")
vim.keymap.set("x", ">", ">gv")
 
-- cycle buffers
vim.keymap.set("n", "<leader>n", vim.cmd.bnext)
vim.keymap.set("n", "<leader>p", vim.cmd.bprev)
 
-- FZF
vim.keymap.set("n", "<leader>f", "<cmd>FZF<CR>")
vim.keymap.set("n", "<leader>fh", "<cmd>FZF ~<CR>")
vim.keymap.set("n", "<leader>fd", "<cmd>FZF /media/luke/data/<CR>")
vim.keymap.set("n", "<leader>tk", "<cmd>FZF ~/toolkit/<CR>")
vim.keymap.set("n", "<leader>fg", "<cmd>call fzf#run({'source': 'git ls-files', 'sink': 'e', 'window': { 'width': 0.9, 'height': 0.6 }})<CR>")
