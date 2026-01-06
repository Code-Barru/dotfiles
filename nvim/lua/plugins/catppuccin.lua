return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        treesitter = true,
        telescope = true,
        nvimtree = true,
        mason = true,
        cmp = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        markdown = true,
        semantic_tokens = true,
      },
      custom_highlights = function(colors)
        return {
          -- Better Svelte highlighting
          ["@tag.svelte"] = { fg = colors.mauve },
          ["@tag.attribute.svelte"] = { fg = colors.yellow },
          ["@string.svelte"] = { fg = colors.green },
        }
      end,
    })

    vim.cmd.colorscheme "catppuccin"
  end,
}
