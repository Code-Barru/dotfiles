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
    { name = "Project", folder = "projects", template = "project.norg", key = "1" },
    { name = "Area", folder = "areas", template = "area.norg", key = "2" },
    { name = "Resource", folder = "resources", template = "resource.norg", key = "3" },
    { name = "Daily", folder = "journal", template = "daily.norg", key = "4" },
  }

  -- Afficher le prompt
  print("Choisir le type de note:")
  for i, note_type in ipairs(note_types) do
    print(string.format("  %s. %s", note_type.key, note_type.name))
  end
  print("\nAppuyez sur une touche (1-4) ou Echap pour annuler...")

  -- Capturer la touche directement
  local char = vim.fn.getchar()
  local key = type(char) == "number" and vim.fn.nr2char(char) or char

  -- Nettoyer l'affichage
  vim.cmd("redraw")

  -- Vérifier si l'utilisateur a annulé (Echap = 27)
  if char == 27 then
    return
  end

  -- Trouver le type de note correspondant
  local choice = nil
  for _, note_type in ipairs(note_types) do
    if key == note_type.key then
      choice = note_type
      break
    end
  end

  -- Si la touche ne correspond à aucune option
  if not choice then
    vim.notify("Option invalide: " .. key, vim.log.levels.WARN)
    return
  end

  -- Cas spécial pour Daily: utiliser le format DD-MM-YYYY
  if choice.name == "Daily" then
    local notes_dir = vim.fn.expand("~/.sync/notes")
    local filename = os.date("%d-%m-%Y") .. ".norg"
    local target_dir = notes_dir .. "/" .. choice.folder
    local target_path = target_dir .. "/" .. filename

    -- Vérifier si le fichier existe déjà
    if vim.fn.filereadable(target_path) == 1 then
      -- Le fichier existe, l'ouvrir
      vim.cmd("edit " .. target_path)
      vim.notify("Journal ouvert: " .. filename, vim.log.levels.INFO)
      return
    end

    -- Le fichier n'existe pas, le créer
    local template_path = notes_dir .. "/meta/templates/" .. choice.template
    local template_file = io.open(template_path, "r")
    if not template_file then
      vim.notify("Template introuvable: " .. template_path, vim.log.levels.ERROR)
      return
    end
    local template_content = template_file:read("*all")
    template_file:close()

    -- Remplacer les placeholders
    local current_date = get_current_date()
    local daily_title = os.date("%A %d %B %Y")  -- Ex: Jeudi 22 Janvier 2026
    local content = template_content
      :gsub("Daily Note", daily_title)
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
    vim.notify("Journal créé: " .. filename, vim.log.levels.INFO)
    return
  end

  -- Étape 2: Demander le nom de la note (pour les autres types)
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
end

return M
