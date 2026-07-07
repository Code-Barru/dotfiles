return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = { "lua", "vim", "vimdoc", "rust", "python", "javascript", "typescript", "tsx", "svelte", "html", "css", "yaml", "markdown", "markdown_inline" },
      auto_install = true,
    })

    -- Force treesitter highlighting for specific filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "svelte", "rust", "javascript", "typescript", "mdx" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
