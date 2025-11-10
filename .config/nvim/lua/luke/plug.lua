require("lazy").setup({
  "junegunn/fzf", -- fzf
  "junegunn/fzf.vim",  -- fzf.vim
  "folke/tokyonight.nvim", -- Tokyo Night Theme
  {
    "nvim-lualine/lualine.nvim", -- lualine
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup()
    end,
  }
})
