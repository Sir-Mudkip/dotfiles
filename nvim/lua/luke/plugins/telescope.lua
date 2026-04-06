return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup{
        defaults = {
          mappings = {
            i = {
              ["<C-h>"] = "which_key"
            }
          },
          -- Add these for global hidden file behavior
          file_ignore_patterns = { "^.git/", "^.gitignore$" },
          hidden = true,  -- Show hidden files by default
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = true,
          },
          live_grep = {
            additional_args = { '--hidden', '--no-ignore' }
          }
        },
        extensions = {}
      }
    end
  },
}
