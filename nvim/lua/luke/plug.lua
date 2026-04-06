-- This is where all the plugins go, like the code blocks in here, just
-- stick everything like seen and the plugins should just work
-- Ideally stick your functions on 1 line if you can
-- If you need multiple then fine
--
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
