local map = vim.keymap.set

-- =============================================================================
-- INSERT MODE NAVIGATION
-- =============================================================================
map("i", "<C-e>", "<End>", { desc = "move end of line" })
map("i", "<C-h>", "<Left>", { desc = "move left" })
map("i", "<C-l>", "<Right>", { desc = "move right" })
map("i", "<C-j>", "<Down>", { desc = "move down" })
map("i", "<C-k>", "<Up>", { desc = "move up" })

-- =============================================================================
-- WINDOW NAVIGATION (handled by tmux-navigator)
-- =============================================================================
-- Note: <C-h>, <C-j>, <C-k>, <C-l> are handled by vim-tmux-navigator plugin

-- =============================================================================
-- GENERAL
-- =============================================================================
map("n", "<Esc>", "<cmd>noh<CR>", { desc = "general clear highlights" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "general copy whole file" })
map("n", ";", ":", { desc = "CMD enter command mode" })

-- =============================================================================
-- BUFFER NAVIGATION
-- =============================================================================
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "goto next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "goto prev buffer" })

-- Smart buffer delete that avoids NvimTree
map("n", "<leader>x","<cmd>bd<CR>", { desc = "close buffer" })
map("n", "<leader>b", "<cmd>enew<CR>", { desc = "new buffer" })

-- =============================================================================
-- TOGGLES
-- =============================================================================
map("n", "<leader>n", "<cmd>set nu!<CR>", { desc = "toggle line number" })
map("n", "<leader>rn", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })

-- =============================================================================
-- LSP
-- =============================================================================
map("n", "<leader>ds", vim.diagnostic.setloclist, { desc = "LSP diagnostic loclist" })

-- LSP keybindings on attach
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
-- NVIMTREE
-- =============================================================================
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "nvimtree toggle window" })
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "nvimtree focus window" })

-- =============================================================================
-- TELESCOPE
-- =============================================================================
map("n", "<leader>pf", "<cmd>Telescope find_files<CR>", { desc = "telescope find files" })
map("n", "<leader>ps", "<cmd>Telescope live_grep<CR>", { desc = "telescope live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "telescope find buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "telescope help page" })
map("n", "<leader>ma", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "telescope find oldfiles" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { desc = "telescope find in current buffer" })
map("n", "<leader>cm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd>Telescope git_status<CR>", { desc = "telescope git status" })
map(
  "n",
  "<leader>fa",
  "<cmd>Telescope find_files follow=true no_ignore=true hidden=true<CR>",
  { desc = "telescope find all files" }
)

-- =============================================================================
-- WHICHKEY
-- =============================================================================
map("n", "<leader>wK", "<cmd>WhichKey<CR>", { desc = "whichkey all keymaps" })
map("n", "<leader>wk", function()
  vim.cmd("WhichKey " .. vim.fn.input("WhichKey: "))
end, { desc = "whichkey query lookup" })

-- =============================================================================
-- NEORG KEYBINDINGS
-- =============================================================================
-- Global keybinding for creating notes (works from anywhere)
map("n", "<leader>nn", function()
  require("config.neorg_commands").create_note()
end, { desc = "neorg create new note" })

-- Directory-specific keybindings (only in .norg files)
require("config.neorg_keybindings").setup()
