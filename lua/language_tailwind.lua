-- =============================================================================
-- Tailwind CSS Language Server Configuration
-- =============================================================================
-- LSP: tailwindcss-language-server
-- Provides: IntelliSense, class completion, diagnostics
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

-- =============================================================================
-- Tailwind CSS LSP Setup
-- =============================================================================

local function setup_tailwind_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('tailwindcss', {
    cmd = { 'tailwindcss-language-server', '--stdio' },
    filetypes = {
      'html',
      'css',
      'scss',
      'sass',
      'less',
      'postcss',
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'svelte',
      'vue',
      'astro',
    },
    root_dir = function(fname)
      return vim.fs.root_pattern('.git', 'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts', 'postcss.config.js', 'postcss.config.cjs', 'postcss.config.mjs', 'postcss.config.ts')(fname)
    end,
    capabilities = capabilities,
    settings = {
      tailwindCSS = {
        classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass', '[klasse]' },
        validate = true,
        lint = {
          cssConflict = 'warning',
          invalidApply = 'error',
        },
        experimental = {
          classRegex = {
            { 'class:list="([^"]*)"', '[\'"]?([^\'">]+)' },
            { 'class\\{([^}]*)\\}', "'([^']+)'" },
            { 'tw`([^`]*)`', '[\'"]?([^\'">]+)' },
            { 'tw\\.join\\(([^)]*)\\)', '[\'"]?([^\'">]+)' },
          },
        },
        includeLanguages = {
          astro = 'html',
          svelte = 'html',
          vue = 'html',
        },
      },
    },
  })

  vim.lsp.enable('tailwindcss')
end

-- =============================================================================
-- Auto-start Tailwind CSS LSP for supported filetypes
-- =============================================================================

autocmd('FileType', {
  pattern = {
    'html',
    'css',
    'scss',
    'sass',
    'less',
    'postcss',
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'svelte',
    'vue',
    'astro',
  },
  callback = setup_tailwind_lsp,
  desc = 'Start Tailwind CSS LSP',
})

-- =============================================================================
-- Also enable tailwindcss for specific project patterns
-- =============================================================================

vim.lsp.enable('tailwindcss')
