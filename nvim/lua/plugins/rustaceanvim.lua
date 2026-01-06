return {
  'mrcjkb/rustaceanvim',
  version = '^6',
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
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Notification when LSP is fully loaded
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
          ['rust-analyzer'] = {
            cargo = {
              allFeatures = true,
            },
          },
        },
      },
      tools = {
        hover_actions = {
          auto_focus = false,
        },
      },
    }
  end,
}
