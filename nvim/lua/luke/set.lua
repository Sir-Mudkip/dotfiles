vim.opt.nu = true
vim.opt.relativenumber = true
 
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
 
vim.opt.smartindent = true
 
vim.opt.swapfile = false
vim.opt.backup = false
 
vim.opt.hlsearch = true
vim.opt.incsearch = true
 
vim.opt.scrolloff = 15
 
vim.opt.updatetime = 50
vim.opt.termguicolors = true

vim.cmd "spell! spelllang=en_gb"
 
vim.cmd "set path+=**"

-- Wrapping
vim.opt.wrap = false

-- Enable wrap for .md and .txt files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true  
    vim.opt_local.colorcolumn = "85"
end,
})
