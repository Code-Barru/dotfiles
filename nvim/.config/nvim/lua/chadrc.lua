---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",
}

M.nvdash = { load_on_startup = true }

M.mason = {
  pkgs = {
    "json-lsp",
    "yaml-language-server",
  },
}

return M
