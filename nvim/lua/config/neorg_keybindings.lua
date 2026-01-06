local M = {}

-- Check if the current buffer is in notes directory
local function is_in_notes_dir()
  local bufpath = vim.api.nvim_buf_get_name(0)
  local notes_dir = vim.fn.expand("~/.sync/notes")
  return string.find(bufpath, notes_dir, 1, true) == 1
end

-- Setup neorg-specific keybindings
function M.setup_neorg_keybindings()
  if not is_in_notes_dir() then
    return
  end

  local map = vim.keymap.set
  local opts = { buffer = true, silent = true }

  -- =============================================================================
  -- QUICK CAPTURE
  -- =============================================================================
  map("n", "<leader>nn", function()
    require("config.neorg_commands").create_note()
  end, vim.tbl_extend("force", opts, { desc = "New note with template" }))

  map("n", "<leader>nj", "<cmd>Neorg journal today<CR>",
    vim.tbl_extend("force", opts, { desc = "Today's journal entry" }))

  -- =============================================================================
  -- PARA NAVIGATION
  -- =============================================================================
  map("n", "<leader>np", "<cmd>e ~/.sync/notes/projects/index.norg<CR>",
    vim.tbl_extend("force", opts, { desc = "Go to Projects" }))

  map("n", "<leader>na", "<cmd>e ~/.sync/notes/areas/index.norg<CR>",
    vim.tbl_extend("force", opts, { desc = "Go to Areas" }))

  map("n", "<leader>nr", "<cmd>e ~/.sync/notes/resources/index.norg<CR>",
    vim.tbl_extend("force", opts, { desc = "Go to Resources" }))

  map("n", "<leader>nc", "<cmd>e ~/.sync/notes/archives/index.norg<CR>",
    vim.tbl_extend("force", opts, { desc = "Go to Archives" }))

  map("n", "<leader>nh", "<cmd>e ~/.sync/notes/index.norg<CR>",
    vim.tbl_extend("force", opts, { desc = "Go to Home/Index" }))

  -- =============================================================================
  -- LINK MANAGEMENT
  -- =============================================================================
  map("n", "<leader>nl", "<cmd>Telescope neorg insert_link<CR>",
    vim.tbl_extend("force", opts, { desc = "Insert link" }))

  map("n", "gf", function()
    local ok = pcall(require, "neorg.modules.core.esupports.hop.module")
    if ok then
      require("neorg.modules.core.esupports.hop.module").public.hop_link()
    end
  end, vim.tbl_extend("force", opts, { desc = "Follow link under cursor" }))

  map("n", "<leader>nb", "<cmd>Telescope neorg find_backlinks<CR>",
    vim.tbl_extend("force", opts, { desc = "Find backlinks" }))

  map("n", "<leader>nf", "<cmd>Telescope neorg find_norg_files<CR>",
    vim.tbl_extend("force", opts, { desc = "Find notes" }))

  -- =============================================================================
  -- TASK/GTD FEATURES
  -- =============================================================================
  map("n", "<C-Space>", function()
    local ok = pcall(require, "neorg.modules.core.qol.todo_items.module")
    if ok then
      require("neorg.modules.core.qol.todo_items.module").public.task_cycle()
    end
  end, vim.tbl_extend("force", opts, { desc = "Toggle task state" }))

  map("n", "<leader>nt", "<cmd>Neorg gtd views<CR>",
    vim.tbl_extend("force", opts, { desc = "GTD task views" }))

  -- =============================================================================
  -- SEARCH & NAVIGATION
  -- =============================================================================
  map("n", "<leader>ns", "<cmd>Telescope neorg search_headings<CR>",
    vim.tbl_extend("force", opts, { desc = "Search headings" }))

  map("n", "<leader>ng", function()
    require('telescope.builtin').live_grep({
      search_dirs = { vim.fn.expand("~/.sync/notes") },
      prompt_title = "Grep in Notes",
    })
  end, vim.tbl_extend("force", opts, { desc = "Grep in notes" }))

  -- =============================================================================
  -- METADATA & UTILITIES
  -- =============================================================================
  map("n", "<leader>nm", "<cmd>Neorg inject-metadata<CR>",
    vim.tbl_extend("force", opts, { desc = "Update metadata" }))

  map("n", "<leader>ntoc", "<cmd>Neorg toc<CR>",
    vim.tbl_extend("force", opts, { desc = "Table of contents" }))

  map("n", "<leader>ne", "<cmd>Neorg export<CR>",
    vim.tbl_extend("force", opts, { desc = "Export note" }))
end

-- Setup autocmd to trigger keybindings
function M.setup()
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    pattern = { "*.norg" },
    callback = function()
      M.setup_neorg_keybindings()
    end,
  })
end

return M
