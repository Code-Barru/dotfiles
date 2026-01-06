-- =============================================================================
-- CAPABILITIES (for nvim-cmp)
-- =============================================================================

local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if has_cmp then
  capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- =============================================================================
-- ON_ATTACH (notification when LSP loads)
-- =============================================================================

local on_attach = function(client, bufnr)
  local filetype = vim.bo[bufnr].filetype

  -- Wait for LSP to be fully loaded before notifying
  vim.defer_fn(function()
    if client and client.server_capabilities then
      vim.notify(
        string.format("LSP '%s' loaded for %s", client.name, filetype),
        vim.log.levels.INFO,
        { title = "LSP Ready" }
      )
    end
  end, 100)
end

-- =============================================================================
-- SERVEURS LSP SIMPLES
-- =============================================================================

local simple_servers = {
  "html",
  "cssls",
}

for _, lsp in ipairs(simple_servers) do
  vim.lsp.config[lsp] = {
    capabilities = capabilities,
    on_attach = on_attach,
  }
  vim.lsp.enable(lsp)
end

-- =============================================================================
-- LUA LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.lua_ls = {
  capabilities = capabilities,
  on_attach = on_attach,
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
vim.lsp.enable('lua_ls')

-- =============================================================================
-- TYPESCRIPT LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.ts_ls = {
  capabilities = capabilities,
  on_attach = on_attach,
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
vim.lsp.enable('ts_ls')

-- =============================================================================
-- SVELTE LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.svelte = {
  capabilities = capabilities,
  on_attach = on_attach,
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
vim.lsp.enable('svelte')

-- =============================================================================
-- TAILWIND CSS LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.tailwindcss = {
  capabilities = capabilities,
  on_attach = on_attach,
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
  },
  settings = {
    tailwindCSS = {
      classAttributes = {
        "class",
        "className",
        "classList",
        "ngClass",
        "class:list"
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
          'class=["\'`]([^"\'`]*)["\'`]',
          'className=["\'`]([^"\'`]*)["\'`]',
        },
      },
    },
  },
  root_dir = vim.fs.root(0, {
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
  }),
}
vim.lsp.enable('tailwindcss')

-- =============================================================================
-- PYTHON LANGUAGE SERVER
-- =============================================================================

vim.lsp.config.pylsp = {
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    pylsp = {
      plugins = {
        pylint = {
          enabled = true,
          args = { '--disable=C' }  -- C0114 = missing-module-docstring
        },
      },
    },
  },
}
vim.lsp.enable('pylsp')
