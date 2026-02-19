-- =============================================================================
-- Astro Language Server Configuration
-- =============================================================================
-- LSP: astro-language-server
-- Formatter: oxfmt (via conform.nvim)
-- Provides: IntelliSense, diagnostics, code actions for Astro components
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_astro_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('astro', {
    cmd = { 'astro-ls', '--stdio' },
    filetypes = { 'astro' },
    capabilities = capabilities,
    settings = {
      astro = {
        typescript = {
          serviceHost = 'ts_ls',
        },
      },
    },
  })

  vim.lsp.enable('astro')
end

autocmd('FileType', {
  pattern = { 'astro' },
  callback = setup_astro_lsp,
  desc = 'Start Astro LSP',
})

vim.lsp.enable('astro')
