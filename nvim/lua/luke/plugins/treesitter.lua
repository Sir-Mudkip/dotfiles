return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          -- Languages you work with
          "bash",
          "python",
          "yaml",
          "json",
          "jsonc",
          "javascript",
          "typescript",
          "tsx",
          "html",
          "css",
          -- Future
          "rust",
          "go",
          "gomod",
          "gosum",
          -- Config / infra
          "lua",
          "luadoc",
          "vim",
          "vimdoc",
          "query",
          "toml",
          "xml",
          "dockerfile",
          -- Docs / notes
          "markdown",
          "markdown_inline",
          "diff",
          "regex",
          "comment",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })

      -- Workaround: nvim-treesitter's #set-lang-from-info-string! directive
      -- is incompatible with neovim 0.12.0's treesitter runtime, causing
      -- "attempt to call method 'range' (a nil value)" on markdown files
      -- with fenced code blocks. Use neovim's built-in injection query instead.
      vim.treesitter.query.set("markdown", "injections", [[
(fenced_code_block
  (info_string
    (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
]])
    end,
  },
}
