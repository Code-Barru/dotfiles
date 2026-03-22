-- Disable default vim syntax in favor of treesitter
vim.g.syntax_on = false

-- Filetypes to ignore for treesitter
local ignore_filetypes = {
  "NvimTree",
  "telescope",
  "lazy",
  "mason",
  "help",
  "checkhealth",
  "lspinfo",
  "qf",
  "TelescopePrompt",
}

-- Ensure treesitter highlighting is prioritized
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local ft = vim.bo.filetype
    if ft ~= "" and not vim.tbl_contains(ignore_filetypes, ft) then
      vim.schedule(function()
        local ok = pcall(vim.treesitter.start)
        if not ok then
          -- Silently fail if no parser available
        end
      end)
    end
  end,
})
