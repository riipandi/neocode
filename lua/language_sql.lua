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
    cmd = { 'sqls', '-config', vim.fn.expand('~/.config/sqls/config.yaml') },
    capabilities = capabilities,
    settings = {
      sqls = {
        commands = {
          executeQuery = {
            edit = {
              workDoneProgress = true,
            },
          },
          executeNamedQuery = {
            edit = {
              workDoneProgress = true,
            },
          },
        },
        connections = {},
      },
    },
  })

  vim.lsp.enable('sqls')
end

autocmd('FileType', {
  pattern = { 'sql', 'mysql', 'pgsql' },
  callback = setup_sql_lsp,
  desc = 'Start SQL LSP',
})

vim.lsp.enable('sqls')
