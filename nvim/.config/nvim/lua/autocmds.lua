require "nvchad.autocmds"

-- Register custom filetypes early so they're available before lazy plugins load
vim.filetype.add({
  extension = { mdx = "mdx" },
})

-- Register treesitter parser for mdx
vim.treesitter.language.register("markdown", "mdx")

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

-- Start mdx_analyzer LSP for MDX files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "mdx",
  callback = function(ev)
    local root = vim.fs.root(ev.buf, { "tsconfig.json", "jsconfig.json", "package.json", ".git" })
    local tsdk = root and (root .. "/node_modules/typescript/lib") or nil
    vim.lsp.start({
      name = "mdx_analyzer",
      cmd = { "mdx-language-server", "--stdio" },
      root_dir = root,
      init_options = {
        typescript = {
          tsdk = tsdk,
        },
      },
    })
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
