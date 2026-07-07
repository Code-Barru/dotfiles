require("nvchad.configs.lspconfig").defaults()

-- =============================================================================
-- CAPABILITIES (for nvim-cmp)
-- =============================================================================

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- =============================================================================
-- SIMPLE SERVERS
-- =============================================================================

local simple_servers = {
  "html",
  "cssls",
}

for _, lsp in ipairs(simple_servers) do
  vim.lsp.config[lsp] = {
    capabilities = capabilities,
  }
end

vim.lsp.enable(simple_servers)

-- =============================================================================
-- LUA LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.lua_ls = {
  capabilities = capabilities,
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
        enable = false,
      },
    },
  },
}
vim.lsp.enable("lua_ls")

-- =============================================================================
-- TYPESCRIPT LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.ts_ls = {
  capabilities = capabilities,
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
vim.lsp.enable("ts_ls")

-- =============================================================================
-- SVELTE LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.svelte = {
  capabilities = capabilities,
  settings = {
    svelte = {
      plugin = {
        html = { completions = { enable = true, emmet = false } },
        svelte = { completions = { enable = true } },
        css = { completions = { enable = true } },
        typescript = {
          diagnostics = { enable = true },
          hover = { enable = true },
          completions = { enable = true },
        },
      },
    },
  },
}
vim.lsp.enable("svelte")

-- =============================================================================
-- TAILWIND CSS LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.tailwindcss = {
  capabilities = capabilities,
  filetypes = {
    "html", "css", "scss", "sass", "postcss",
    "javascript", "javascriptreact", "typescript", "typescriptreact",
    "svelte", "vue", "astro",
  },
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", "classList", "ngClass", "class:list" },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning",
      },
      validate = true,
      experimental = {
        classRegex = {
          'class=["\'`]([^"\'`]*)["\'`]',
          'className=["\'`]([^"\'`]*)["\'`]',
        },
      },
    },
  },
  root_dir = vim.fs.root(0, {
    "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts",
    "postcss.config.js", "postcss.config.cjs", "postcss.config.mjs", "postcss.config.ts",
    "package.json", "node_modules", ".git",
  }),
}
vim.lsp.enable("tailwindcss")

-- =============================================================================
-- PYTHON LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.pylsp = {
  capabilities = capabilities,
  settings = {
    pylsp = {
      plugins = {
        pylint = {
          enabled = true,
          args = { "--disable=C" },
        },
      },
    },
  },
}
vim.lsp.enable("pylsp")

-- =============================================================================
-- CLANGD (C/C++)
-- =============================================================================

vim.lsp.config.clangd = {
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
  },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_dir = vim.fs.root(0, {
    "compile_commands.json", "compile_flags.txt", "CMakeLists.txt", "Makefile", ".git",
  }),
}
vim.lsp.enable("clangd")

-- =============================================================================
-- JSON LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.jsonls = {
  capabilities = capabilities,
  settings = {
    json = {
      validate = { enable = true },
    },
  },
  init_options = { provideFormatter = true },
}
vim.lsp.enable("jsonls")

-- =============================================================================
-- YAML LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.yamlls = {
  capabilities = capabilities,
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      schemaStore = {
        enable = true,
        url = "https://www.schemastore.org/api/json/catalog.json",
      },
      schemas = {},
    },
  },
}
vim.lsp.enable("yamlls")

-- MDX ANALYZER is started via autocmds.lua (needs early loading before lazy plugins)
