-- Configure LSP diagnostics to show inline
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,  -- Keep diagnostics visible in insert mode
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
  },
})

-- Customize diagnostic signs
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
