return {
  -- Formatter
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- Treesitter (override NvChad defaults to add our parsers)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "rust", "python",
        "javascript", "typescript", "svelte",
        "html", "css",
        "markdown", "markdown_inline",
        "norg",
      },
    },
  },

  -- Rust
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if has_cmp then
        capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
      end

      vim.g.rustaceanvim = {
        server = {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
            vim.defer_fn(function()
              if client and client.server_capabilities then
                vim.notify(
                  string.format("LSP '%s' loaded for rust", client.name),
                  vim.log.levels.INFO,
                  { title = "LSP Ready" }
                )
              end
            end, 100)
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
            },
          },
        },
        tools = {
          hover_actions = { auto_focus = false },
        },
      }
    end,
  },
}
