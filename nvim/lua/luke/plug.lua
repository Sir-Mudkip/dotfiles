-- This is where all the plugins go, like the code blocks in here, just
-- stick everything like seen and the plugins should just work
-- Ideally stick your functions on 1 line if you can
-- If you need multiple then fine
--
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	spec = {
-- import/override with your plugins    
		{ import = "luke.plugins" }, --import all plugins in that folder
  },
	performance = {
		rtp = {
		 -- disable some rtp plugins
	      disabled_plugins = {
			"gzip",
	        -- "matchit",
	        -- "matchparen",
	        -- "netrwPlugin",
	        "tarPlugin",
	        "tohtml",
	        "tutor",
	        "zipPlugin",
      },
    },
  },
})
