-- LSP configuration via the built-in vim.lsp.config / vim.lsp.enable API
-- (Neovim 0.11+). Mason installs the server binaries; nvim-lspconfig only
-- supplies the per-server defaults (cmd, filetypes, root markers) that
-- vim.lsp.config picks up automatically.
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Global defaults applied to every server
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Per-server overrides

      -- PowerShell Editor Services needs its bundle path pointing at the
      -- mason-installed package; the nvim-lspconfig default leaves it nil.
      vim.lsp.config("powershell_es", {
        init_options = {
          bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
        },
      })

      -- yamlls with SchemaStore integration for Kubernetes, GitHub Actions,
      -- docker-compose, etc. Files matching the glob patterns below also
      -- get an explicit Kubernetes schema.
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
            schemas = {
              kubernetes = { "*.k8s.yaml", "k8s/**/*.yaml", "kubernetes/**/*.yaml", "manifests/**/*.yaml" },
              ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
              ["https://json.schemastore.org/github-action.json"] = ".github/action.{yml,yaml}",
              ["https://json.schemastore.org/docker-compose.json"] = "docker-compose*.{yml,yaml}",
              ["https://json.schemastore.org/ansible-playbook.json"] = "playbook*.{yml,yaml}",
            },
            format = { enable = true },
            validate = true,
            completion = true,
            hover = true,
          },
          redhat = { telemetry = { enabled = false } },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable servers. Any extra config beyond the nvim-lspconfig default
      -- can be added via another vim.lsp.config(name, {...}) call above.
      vim.lsp.enable({
        "lua_ls",
        "marksman",
        "bashls",
        "pyright",
        "yamlls",
        "jsonls",
        "ts_ls",
        "rust_analyzer",
        "gopls",
        "powershell_es",
      })

      -- Buffer-local keymaps, applied whenever an LSP attaches to a buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, silent = true, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gD", vim.lsp.buf.declaration, "Go to declaration")
          map("gi", vim.lsp.buf.implementation, "Go to implementation")
          map("gr", vim.lsp.buf.references, "References")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Previous diagnostic")
          map("]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
          map("<leader>dd", vim.diagnostic.open_float, "Show line diagnostics")
        end,
      })

      -- Diagnostic display tweaks
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = true },
      })
    end,
  },
}
