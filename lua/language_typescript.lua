-- =============================================================================
-- TypeScript / JavaScript Language Servers
-- =============================================================================
-- ts_ls (primary), oxlint (linter), denols (Deno projects).
-- Commands, filetypes and root detection come from nvim-lspconfig: ts_ls steps
-- aside inside Deno projects and denols only starts where deno.json exists, so
-- no FileType juggling is needed. Capabilities come from plugin_completion.lua.
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

vim.lsp.config('denols', {
    settings = {
        deno = {
            enable = true,
            suggest = { autoImports = true, completeFunctionCalls = true },
            lint = { enabled = true },
            codeLens = { implementations = true, references = true, test = true },
        },
    },
})

vim.lsp.enable({ 'ts_ls', 'oxlint', 'denols' })
