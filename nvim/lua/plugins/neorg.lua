return {
  "nvim-neorg/neorg",
  lazy = false,
  version = "*",
  config = function()
    require("neorg").setup({
      load = {
        -- Core modules
        ["core.defaults"] = {},
        ["core.concealer"] = {
          config = {
            icon_preset = "diamond",  -- Icônes jolies
            folds = true,
            init_open_folds = "always",  -- Toujours ouvrir les folds au démarrage
            icons = {
              code_block = {
                conceal = true,  -- Cacher les délimiteurs de code blocks
              },
            },
          },
        },
        ["core.dirman"] = {
          config = {
            workspaces = {
              notes = "~/.sync/notes",
            },
            default_workspace = "notes",
            index = "index.norg",
          },
        },

        -- PARA modules
        ["core.journal"] = {
          config = {
            workspace = "notes",
            journal_folder = "journal",
            strategy = "flat",
          },
        },
        ["core.qol.todo_items"] = {},  -- Gestion des tâches
        ["core.ui.calendar"] = {},  -- Calendrier

        -- Intégrations
        ["core.completion"] = {
          config = {
            engine = "nvim-cmp",
          },
        },
        ["core.integrations.nvim-cmp"] = {},
      },
    })
  end,
}
