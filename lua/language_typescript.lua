-- =============================================================================
-- TypeScript, React, Lit, and Deno Language Server Configuration
-- =============================================================================
-- LSP: ts_ls (primary), oxlint (linter), deno (optional, disabled by default)
-- Formatter: oxfmt (via conform.nvim with organize imports)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

-- =============================================================================
-- TypeScript Language Server (ts_ls)
-- =============================================================================

local function setup_typescript_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('ts_ls', {
    capabilities = capabilities,
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = {
          autoImports = true,
          includeAutoImports = true,
        },
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = {
          autoImports = true,
          includeAutoImports = true,
        },
      },
    },
  })

  vim.lsp.enable('ts_ls')
end

-- =============================================================================
-- Oxlint LSP (linter for TypeScript/JavaScript)
-- =============================================================================

local function setup_oxlint_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('oxlint', {
    cmd = { 'oxlint_language_server' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'astro',
      'svelte',
      'vue',
    },
    root_dir = function(fname)
      return vim.fs.root_pattern('.git', '.oxlintrc.json', 'oxlint.config.ts')(fname)
    end,
    capabilities = capabilities,
    settings = {},
  })

  vim.lsp.enable('oxlint')
end

-- =============================================================================
-- Deno LSP (disabled by default to avoid conflict with ts_ls)
-- =============================================================================

local function setup_deno_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('deno', {
    cmd = { 'deno', 'lsp' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
      'json',
      'jsonc',
      'markdown',
      'toml',
      'yaml',
    },
    root_dir = function(fname)
      return vim.fs.root_pattern('deno.json', 'deno.jsonc', '.git')(fname)
    end,
    capabilities = capabilities,
    settings = {
      deno = {
        enable = true,
        suggest = {
          autoImports = true,
          completeFunctionCalls = true,
        },
        lint = {
          enabled = true,
        },
        codeLens = {
          implementations = true,
          references = true,
          test = true,
        },
      },
    },
  })
end

-- =============================================================================
-- Auto-start LSP servers by filetype
-- =============================================================================

autocmd('FileType', {
  pattern = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'astro',
    'svelte',
    'vue',
  },
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    local is_deno = vim.fn.filereadable(vim.fn.expand('%:p:h') .. '/deno.json') == 1
                   or vim.fn.filereadable(vim.fn.expand('%:p:h') .. '/deno.jsonc') == 1

    -- Use deno if deno.json exists, otherwise use ts_ls + oxlint
    if is_deno then
      vim.lsp.enable('deno')
      pcall(vim.lsp.start, { name = 'deno', cmd = { 'deno', 'lsp' } })
    else
      setup_typescript_lsp()
      setup_oxlint_lsp()
    end
  end,
  desc = 'Start TypeScript/JS LSP (ts_ls + oxlint or deno)',
})

-- =============================================================================
-- Auto-start Deno LSP when deno.json is present
-- =============================================================================

autocmd('FileType', {
  pattern = { 'javascript', 'typescript', 'json', 'jsonc', 'markdown', 'toml', 'yaml' },
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    local bufdir = vim.fn.fnamemodify(bufname, ':p:h')
    local root_dir = vim.fs.root_pattern('.git', 'deno.json', 'deno.jsonc')(bufname)

    if root_dir and vim.fn.isdirectory(root_dir) == 1 then
      local has_deno = vim.fn.filereadable(root_dir .. '/deno.json') == 1
                     or vim.fn.filereadable(root_dir .. '/deno.jsonc') == 1

      if has_deno then
        vim.lsp.enable('deno')
        pcall(vim.lsp.start, { name = 'deno', cmd = { 'deno', 'lsp' }, root_dir = root_dir })
      end
    end
  end,
  desc = 'Auto-start Deno LSP when deno.json exists',
})

-- =============================================================================
-- Enable LSP servers (available but not auto-started unless triggered)
-- =============================================================================

vim.lsp.enable({ 'ts_ls', 'oxlint', 'deno' })
