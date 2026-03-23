require "nvchad.autocmds"

-- Filetypes to ignore for treesitter auto-start
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
  "nvdash",
}

-- Auto-reload buffers modified externally (e.g. by LSP formatting other files)
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  callback = function()
    vim.cmd "checktime"
  end,
})

-- Ensure treesitter highlighting is prioritized on BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local ft = vim.bo.filetype
    if ft ~= "" and not vim.tbl_contains(ignore_filetypes, ft) then
      vim.schedule(function()
        pcall(vim.treesitter.start)
      end)
    end
  end,
})
