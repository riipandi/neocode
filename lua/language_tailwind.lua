-- =============================================================================
-- Tailwind CSS Language Server
-- =============================================================================
-- Command, filetypes and root detection (a tailwind/postcss config is required,
-- so it stays quiet in non-Tailwind projects) come from nvim-lspconfig.
-- =============================================================================

vim.lsp.config('tailwindcss', {
    settings = {
        tailwindCSS = {
            classAttributes = { 'class', 'className', 'class:list', 'classList', 'ngClass', '[klasse]' },
            validate = true,
            lint = {
                cssConflict = 'warning',
                invalidApply = 'error',
            },
            experimental = {
                classRegex = {
                    { 'class:list="([^"]*)"',   '[\'"]?([^\'">]+)' },
                    { 'class\\{([^}]*)\\}',     "'([^']+)'" },
                    { 'tw`([^`]*)`',            '[\'"]?([^\'">]+)' },
                    { 'tw\\.join\\(([^)]*)\\)', '[\'"]?([^\'">]+)' },
                },
            },
            includeLanguages = {
                astro = 'html',
                svelte = 'html',
                vue = 'html',
            },
        },
    },
})

vim.lsp.enable('tailwindcss')
