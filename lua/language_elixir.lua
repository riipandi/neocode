-- =============================================================================
-- Elixir & Phoenix Language Server Configuration
-- =============================================================================
-- LSP: elixirls (Elixir LS)
-- Formatter: mix format (via conform.nvim)
-- Supports: Elixir, Phoenix, Heex, EEx templates
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_elixir_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('elixirls', {
    cmd = { 'elixir-ls' },
    capabilities = capabilities,
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
        fetchDeps = true,
        formatter = "mix format",
      },
    },
  })

  vim.lsp.enable('elixirls')
end

autocmd('FileType', {
  pattern = { 'elixir', 'eex', 'heex', 'surface' },
  callback = setup_elixir_lsp,
  desc = 'Start Elixir LSP',
})

vim.lsp.enable('elixirls')
