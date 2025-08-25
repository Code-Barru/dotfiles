require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

-- =============================================================================
-- SERVEURS LSP SIMPLES
-- =============================================================================

local simple_servers = {
  "html",           -- html-lsp
  "cssls",          -- css-lsp  
}

for _, lsp in ipairs(simple_servers) do
  lspconfig[lsp].setup {}
end

-- =============================================================================
-- LUA LANGUAGE SERVER
-- =============================================================================

lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/luv/library",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
      completion = {
        callSnippet = "Replace",
      },
      format = {
        enable = false, -- On utilise stylua pour le formatage
      },
    },
  },
}
-- =============================================================================
-- TYPESCRIPT LANGUAGE SERVER
-- =============================================================================

lspconfig.ts_ls.setup {
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
}

-- =============================================================================
-- SVELTE LANGUAGE SERVER
-- =============================================================================

lspconfig.svelte.setup {
  settings = {
    svelte = {
      plugin = {
        html = {
          completions = {
            enable = true,
            emmet = false,
          },
        },
        svelte = {
          completions = {
            enable = true,
          },
        },
        css = {
          completions = {
            enable = true,
          },
        },
        typescript = {
          diagnostics = {
            enable = true,
          },
          hover = {
            enable = true,
          },
          completions = {
            enable = true,
          },
        },
      },
    },
  },
}

-- =============================================================================
-- TAILWIND CSS LANGUAGE SERVER
-- =============================================================================

lspconfig.tailwindcss.setup {
  filetypes = {
    "html",
    "css",
    "scss",
    "sass",
    "postcss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "svelte",
    "vue",
    "astro",
    "rust", -- Pour les macros comme leptos
  },
  settings = {
    tailwindCSS = {
      classAttributes = { 
        "class", 
        "className", 
        "classList", 
        "ngClass",
        "class:list" -- Pour Astro
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning"
      },
      validate = true,
      experimental = {
        classRegex = {
          -- Pour Rust/leptos
          'class=["\'`]([^"\'`]*)["\'`]',
          'className=["\'`]([^"\'`]*)["\'`]',
        },
      },
    },
  },
  root_dir = lspconfig.util.root_pattern(
    "tailwind.config.js",
    "tailwind.config.cjs",
    "tailwind.config.mjs",
    "tailwind.config.ts",
    "postcss.config.js",
    "postcss.config.cjs", 
    "postcss.config.mjs",
    "postcss.config.ts",
    "package.json",
    "node_modules",
    ".git"
  ),
}
