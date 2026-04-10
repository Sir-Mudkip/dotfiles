-- In lua/luke/plugins/mason.lua
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",    -- Lua (nvim config)
          "marksman",  -- Markdown
          "bashls",    -- Bash
          "pyright",   -- Python
          "yamlls",    -- YAML
          "jsonls",    -- JSON
          "ts_ls",         -- JavaScript / TypeScript
          "rust_analyzer", -- Rust
          "gopls",         -- Go
          "powershell_es", -- PowerShell
        },
        -- We set servers up explicitly in lsp.lua; don't let mason-lspconfig
        -- auto-enable them or they'll start twice.
        automatic_enable = false,
      })
    end
  },
}
