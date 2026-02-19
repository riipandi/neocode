-- =============================================================================
-- Rust Language Server Configuration
-- =============================================================================
-- LSP: rust-analyzer
-- Formatter: rustfmt (via conform.nvim)
-- Additional: crates.nvim for dependency management
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

vim.pack.add({
  { src = "https://github.com/saecki/crates.nvim" },
})

require('crates').setup({})

local function setup_rust_analyzer()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('rust_analyzer', {
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          runBuildScripts = true,
        },
        checkOnSave = {
          command = "clippy",
        },
        completion = {
          autoImport = true,
          snippets = "custom",
        },
        diagnostics = {
          enable = true,
        },
        hover = {
          actions = {
            enable = true,
          },
          documentation = true,
          links = true,
        },
        procMacro = {
          enable = true,
        },
      },
    },
  })

  vim.lsp.enable('rust_analyzer')
end

autocmd('FileType', {
  pattern = { 'rust' },
  callback = setup_rust_analyzer,
  desc = 'Start Rust Analyzer LSP',
})

vim.lsp.enable('rust_analyzer')
