-- =============================================================================
-- Zig Language Server Configuration
-- =============================================================================
-- LSP: zls (Zig Language Server)
-- Formatter: zigfmt (via conform.nvim)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_zig_lsp()
    local capabilities = {}
    local ok, blink = pcall(require, 'blink.cmp')
    if ok then
        capabilities = blink.get_lsp_capabilities()
    end

    vim.lsp.config('zls', {
        capabilities = capabilities,
        settings = {},
    })

    vim.lsp.enable('zls')
end

autocmd('FileType', {
    pattern = { 'zig' },
    callback = setup_zig_lsp,
    desc = 'Start Zig LSP',
})

vim.lsp.enable('zls')
