return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",  -- Utiliser master au lieu de main (compatible avec neorg)
  build = ":TSUpdate",
  config = function()
    local status_ok, configs = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
      return
    end

    configs.setup({
      ensure_installed = { "lua", "vim", "vimdoc", "rust", "python", "javascript", "typescript", "svelte", "html", "css", "markdown", "markdown_inline", "norg" },
      sync_install = false,
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    })

    -- Force treesitter highlighting for specific filetypes
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "svelte", "rust", "javascript", "typescript" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
