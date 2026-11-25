-- =============================================================================
-- TypeScript / JavaScript Language Servers
-- =============================================================================
-- ts_ls (primary), oxlint (linter).
-- Commands, filetypes and root detection come from nvim-lspconfig; capabilities
-- come from plugin_completion.lua.
-- Formatter: oxfmt (via conform.nvim with organize imports)
-- =============================================================================

local ts_settings = {
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
}

vim.lsp.config('ts_ls', {
    settings = { typescript = ts_settings, javascript = ts_settings },
})

vim.lsp.enable({ 'ts_ls', 'oxlint' })
