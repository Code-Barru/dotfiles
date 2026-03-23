require "nvchad.options"

local o = vim.o
local opt = vim.opt

-- Overrides / additions to NvChad defaults

-- Line numbers (NvChad enables number but not relativenumber)
o.relativenumber = true

-- Cursorline: NvChad sets cursorlineopt = "number", we want the full line
o.cursorline = true
o.cursorlineopt = "both"

-- Search settings (NvChad has ignorecase + smartcase, we add these)
o.hlsearch = true
o.incsearch = true

-- Scroll context
o.scrolloff = 8

-- Disable swap/backup (NvChad doesn't set these)
opt.swapfile = false
opt.backup = false
