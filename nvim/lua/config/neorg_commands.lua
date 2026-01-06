local M = {}

-- Fonction pour obtenir la date actuelle au format YYYY-MM-DD
local function get_current_date()
  return os.date("%Y-%m-%d")
end

-- Fonction pour convertir le nom en kebab-case (pour les noms de fichiers)
local function to_kebab_case(str)
  return str:lower():gsub("%s+", "-"):gsub("[^%w%-]", "")
end

-- Fonction principale de création de note
function M.create_note()
  -- Étape 1: Choisir le type de note
  local note_types = {
    { name = "Project", folder = "projects", template = "project.norg" },
    { name = "Area", folder = "areas", template = "area.norg" },
    { name = "Resource", folder = "resources", template = "resource.norg" },
    { name = "Daily", folder = "journal", template = "daily.norg" },
  }

  vim.ui.select(note_types, {
    prompt = "Choisir le type de note:",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if not choice then
      return -- L'utilisateur a annulé
    end

    -- Étape 2: Demander le nom de la note
    vim.ui.input({
      prompt = "Nom de la note: ",
      default = "",
    }, function(note_name)
      if not note_name or note_name == "" then
        return -- L'utilisateur a annulé ou n'a rien saisi
      end

      -- Chemins
      local notes_dir = vim.fn.expand("~/.sync/notes")
      local template_path = notes_dir .. "/meta/templates/" .. choice.template
      local filename = to_kebab_case(note_name) .. ".norg"
      local target_dir = notes_dir .. "/" .. choice.folder
      local target_path = target_dir .. "/" .. filename

      -- Vérifier si le fichier existe déjà
      if vim.fn.filereadable(target_path) == 1 then
        vim.notify("Le fichier existe déjà: " .. target_path, vim.log.levels.WARN)
        return
      end

      -- Lire le template
      local template_file = io.open(template_path, "r")
      if not template_file then
        vim.notify("Template introuvable: " .. template_path, vim.log.levels.ERROR)
        return
      end
      local template_content = template_file:read("*all")
      template_file:close()

      -- Remplacer les placeholders
      local current_date = get_current_date()
      local content = template_content
        :gsub("Project Title", note_name)
        :gsub("Area Title", note_name)
        :gsub("Resource Title", note_name)
        :gsub("Daily Note", note_name)
        :gsub("created: %d%d%d%d%-%d%d%-%d%d", "created: " .. current_date)
        :gsub("updated: %d%d%d%d%-%d%d%-%d%d", "updated: " .. current_date)

      -- Créer le fichier
      local target_file = io.open(target_path, "w")
      if not target_file then
        vim.notify("Impossible de créer le fichier: " .. target_path, vim.log.levels.ERROR)
        return
      end
      target_file:write(content)
      target_file:close()

      -- Ouvrir le fichier
      vim.cmd("edit " .. target_path)
      vim.notify("Note créée: " .. filename, vim.log.levels.INFO)
    end)
  end)
end

return M
