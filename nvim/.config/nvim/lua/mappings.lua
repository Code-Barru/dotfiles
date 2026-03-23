require "nvchad.mappings"

local map = vim.keymap.set

-- =============================================================================
-- GENERAL
-- =============================================================================
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Override NvChad window nav mappings with vim-tmux-navigator
map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  { desc = "tmux navigate left" })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>",  { desc = "tmux navigate down" })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>",    { desc = "tmux navigate up" })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { desc = "tmux navigate right" })

-- =============================================================================
-- NVIMTREE (NvChad uses <C-n>, we add <C-b> as well)
-- =============================================================================
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })

-- =============================================================================
-- TELESCOPE (keep NvChad defaults + add our own aliases)
-- =============================================================================
map("n", "<leader>pf", "<cmd>Telescope find_files<CR>", { desc = "telescope find files" })
map("n", "<leader>ps", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })

-- =============================================================================
-- LSP KEYBINDINGS ON ATTACH
-- =============================================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    map("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    map("n", "<leader>ra", vim.lsp.buf.rename, opts)
    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
  end,
})

-- =============================================================================
-- NEORG
-- =============================================================================
-- Global keybinding for creating notes (works from anywhere)
map("n", "<leader>nn", function()
  require("configs.neorg_commands").create_note()
end, { desc = "neorg create new note" })

-- Directory-specific keybindings (only in .norg files)
require("configs.neorg_keybindings").setup()
