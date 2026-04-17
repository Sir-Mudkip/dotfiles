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

      -- Workaround: nvim-treesitter's bash heredoc injection uses
      -- #downcase! on an optional (heredoc_end) node. When the heredoc is
      -- unterminated (common while typing), neovim 0.12 calls :range() on
      -- a nil node and throws "attempt to call method 'range' (a nil value)".
      -- Ship the rest of the injections query without the heredoc rule.
      vim.treesitter.query.set("bash", "injections", [[
((comment) @injection.content
  (#set! injection.language "comment"))

((regex) @injection.content
  (#set! injection.language "regex"))

((command
  name: (command_name) @_command
  .
  argument: [
    (string) @injection.content
    (concatenation
      (string) @injection.content)
    (raw_string) @injection.content
    (concatenation
      (raw_string) @injection.content)
  ])
  (#eq? @_command "printf")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "printf"))

((command
  name: (command_name) @_command
  argument: (word) @_arg
  .
  (_)
  .
  argument: [
    (string) @injection.content
    (concatenation
      (string) @injection.content)
    (raw_string) @injection.content
    (concatenation
      (raw_string) @injection.content)
  ])
  (#eq? @_command "printf")
  (#eq? @_arg "-v")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "printf"))

((command
  name: (command_name) @_command
  argument: (word) @_arg
  .
  argument: [
    (string) @injection.content
    (concatenation
      (string) @injection.content)
    (raw_string) @injection.content
    (concatenation
      (raw_string) @injection.content)
  ])
  (#eq? @_command "printf")
  (#eq? @_arg "--")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "printf"))

((command
  name: (command_name) @_command
  .
  argument: [
    (string)
    (raw_string)
  ] @injection.content)
  (#eq? @_command "bind")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.include-children)
  (#set! injection.language "readline"))
]])
    end,
  },
}
