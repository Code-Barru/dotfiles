local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },

  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == "rust" then
      return { timeout_ms = 500, lsp_fallback = true }
    end
  end,
}

return options
