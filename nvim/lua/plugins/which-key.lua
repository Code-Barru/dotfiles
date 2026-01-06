return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- Configuration options
    preset = "modern", -- Options: "classic", "modern", "helix"
    delay = 300, -- Délai avant d'afficher which-key (en ms)

    -- Icônes
    icons = {
      breadcrumb = "»", -- symbole pour la breadcrumb
      separator = "➜", -- symbole entre key et description
      group = "+", -- symbole pour les groupes
    },

    -- Désactiver which-key pour certains modes si nécessaire
    disable = {
      ft = {}, -- filetypes à désactiver
      bt = {}, -- buftypes à désactiver
    },
  },

  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Définir les groupes pour organiser les menus
    -- which-key v3 utilise wk.add() au lieu de wk.register()
    wk.add({
      { "<leader>f", group = "Find" },
      { "<leader>p", group = "Project" },
      { "<leader>g", group = "Git" },
      { "<leader>w", group = "WhichKey" },
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Diagnostics" },
      { "<leader>r", group = "Refactor" },
      { "<leader>n", group = "Notes/Neorg" },
    })
  end,
}
