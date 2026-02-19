-- =============================================================================
-- SQL Language Server Configuration
-- =============================================================================
-- LSP: sqls (SQL Language Server)
-- Supports: PostgreSQL, SQLite, MySQL
-- Formatter: sql-formatter (via conform.nvim)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_sql_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('sqls', {
    capabilities = capabilities,
    settings = {},
  })

  vim.lsp.enable('sqls')
end

autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'pgsql' },
  callback = setup_sql_lsp,
  desc = 'Start SQL LSP',
})

vim.lsp.enable('sqls')
