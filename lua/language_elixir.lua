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

  local mix_exs_path = vim.fn.findfile('mix.exs', ';')
  local is_phoenix = mix_exs_path ~= '' and vim.fn.filereadable(mix_exs_path) == 1

  vim.lsp.config('elixirls', {
    cmd = { 'elixir-ls' },
    capabilities = capabilities,
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
        dialyzerFormat = "dialyxir_long",
        fetchDeps = true,
        fparser = "fparser",
        formatter = "mix format",
        generateSpecs = true,
        highlightedensitites = { "keyword", "atom", "string", "number", "variable" },
        importOpportunities = "",
        knownProjects = is_phoenix and "phoenix" or "default",
        languageServerFeatures = {
          codeLens = true,
        },
        macroExpansion = true,
        output = "concatenated",
        patternCase = "snake_case",
        preferredChainLength = 80,
        signOtpCompleting = true,
        suggestSpecs = true,
        tagsToRefresh = { "todo", "FIXME", "OPTIMIZE", "HACK", "NOTE" },
        treeSitterEnabled = true,
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
