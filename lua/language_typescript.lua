-- =============================================================================
-- TypeScript, React, Lit, and Deno Language Server Configuration
-- =============================================================================
-- LSP: ts_ls (primary), oxlint (linter), deno (optional, disabled by default)
-- Formatter: oxfmt (via conform.nvim with organize imports)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

-- =============================================================================
-- TypeScript Language Server (ts_ls)
-- =============================================================================

local function setup_typescript_lsp()
    local capabilities = {}
    local ok, blink = pcall(require, 'blink.cmp')
    if ok then
        capabilities = blink.get_lsp_capabilities()
    end

    vim.lsp.config('ts_ls', {
        capabilities = capabilities,
        settings = {
            typescript = {
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
            },
            javascript = {
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
            },
        },
    })
end

-- =============================================================================
-- Oxlint LSP (linter for TypeScript/JavaScript)
-- =============================================================================

local function setup_oxlint_lsp()
    local capabilities = {}
    local ok, blink = pcall(require, 'blink.cmp')
    if ok then
        capabilities = blink.get_lsp_capabilities()
    end

    vim.lsp.config('oxlint', {
        cmd = { 'oxlint_language_server' },
        filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
            'astro',
            'svelte',
            'vue',
        },
        root_dir = function(fname)
            local patterns = { '.git', '.oxlintrc.json', 'oxlint.config.ts' }
            for _, pattern in ipairs(patterns) do
                local found = vim.fn.finddir(pattern, fname .. ';')
                if found ~= '' then
                    return vim.fn.fnamemodify(found, ':h')
                end
                found = vim.fn.findfile(pattern, fname .. ';')
                if found ~= '' then
                    return vim.fn.fnamemodify(found, ':h')
                end
            end
            return nil
        end,
        capabilities = capabilities,
        settings = {},
    })
end

-- =============================================================================
-- Deno LSP (disabled by default to avoid conflict with ts_ls)
-- =============================================================================

local function setup_deno_lsp()
    local capabilities = {}
    local ok, blink = pcall(require, 'blink.cmp')
    if ok then
        capabilities = blink.get_lsp_capabilities()
    end

    vim.lsp.config('deno', {
        cmd = { 'deno', 'lsp' },
        filetypes = {
            'javascript',
            'javascriptreact',
            'javascript.jsx',
            'typescript',
            'typescriptreact',
            'typescript.tsx',
            'json',
            'jsonc',
            'markdown',
            'toml',
            'yaml',
        },
        root_dir = function(fname)
            local patterns = { '.git', 'deno.json', 'deno.jsonc' }
            for _, pattern in ipairs(patterns) do
                local found = vim.fn.finddir(pattern, fname .. ';')
                if found ~= '' then
                    return vim.fn.fnamemodify(found, ':h')
                end
                found = vim.fn.findfile(pattern, fname .. ';')
                if found ~= '' then
                    return vim.fn.fnamemodify(found, ':h')
                end
            end
            return nil
        end,
        capabilities = capabilities,
        settings = {
            deno = {
                enable = true,
                suggest = {
                    autoImports = true,
                    completeFunctionCalls = true,
                },
                lint = {
                    enabled = true,
                },
                codeLens = {
                    implementations = true,
                    references = true,
                    test = true,
                },
            },
        },
    })
end

-- =============================================================================
-- Configure once, enable once
-- =============================================================================
-- Re-running vim.lsp.enable()/vim.lsp.start() per FileType event spawned a
-- second client for the same buffer (deno#1 + deno#2). Configuration happens
-- here; buffer-level decisions only toggle clients that already attached.

setup_typescript_lsp()
setup_oxlint_lsp()
setup_deno_lsp()

vim.lsp.enable({ 'ts_ls', 'oxlint' })

-- Deno projects: enable the Deno LSP for that root and stop the ts_ls/oxlint
-- clients that already attached to this buffer.
local deno_group = vim.api.nvim_create_augroup('ts_deno_detect', { clear = true })

autocmd('FileType', {
    group = deno_group,
    pattern = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'astro',
        'svelte',
        'vue',
    },
    callback = function(args)
        local name = vim.api.nvim_buf_get_name(args.buf)
        if name == '' then
            return
        end

        local deno_root = vim.fs.find({ 'deno.json', 'deno.jsonc' }, {
            upward = true,
            path = vim.fs.dirname(name),
        })[1]
        if not deno_root then
            return
        end

        vim.lsp.enable('deno')
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if client.name == 'ts_ls' or client.name == 'oxlint' then
                client:stop()
            end
        end
    end,
    desc = 'Use the Deno LSP inside deno projects',
})
