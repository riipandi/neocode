-- =============================================================================
-- Go Language Server Configuration
-- =============================================================================
-- LSP: gopls
-- Formatter: gofmt (via conform.nvim)
-- Tools: goimports, golangci-lint (via Mason)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_go_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('gopls', {
    capabilities = capabilities,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        codelenses = {
          gc_details = true,
          generate = true,
          run_vulncheck_exp = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
        },
        completeUnimported = true,
        goimports = "goimports",
        linksInHover = true,
       hoverKind = "FullDocumentation",
        analyses = {
          fillstruct = true,
          nilness = true,
          shadow = true,
          unusedparams = true,
          unreachable = false,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        usePlaceholders = true,
        symbolMatcher = "fuzzy",
        snippets = {
          keyword = true,
        },
        format = "gofmt",
        matcher = "fuzzy",
      },
    },
  })

  vim.lsp.enable('gopls')
end

autocmd('FileType', {
  pattern = { 'go', 'gomod' },
  callback = setup_go_lsp,
  desc = 'Start Go LSP',
})

vim.lsp.enable('gopls')
