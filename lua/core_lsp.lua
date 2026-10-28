-- ============================================================================
-- Core LSP Configuration
-- ============================================================================

local snacks = require("snacks")
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Find the project root for a buffer. root_dir handlers receive
-- (bufnr, on_dir) from vim.lsp.config, so the argument is a buffer number.
local function buffer_root(bufnr, patterns)
    local name = type(bufnr) == "number" and vim.api.nvim_buf_get_name(bufnr) or tostring(bufnr)
    local dir = (name ~= "" and vim.fs.dirname(name)) or vim.fn.getcwd()
    local path = dir
    for _, pattern in ipairs(patterns) do
        local found = vim.fn.finddir(pattern, path .. ';')
        if found ~= '' then
            return vim.fn.fnamemodify(found, ':h')
        end
        found = vim.fn.findfile(pattern, path .. ';')
        if found ~= '' then
            return vim.fn.fnamemodify(found, ':h')
        end
    end
    return dir
end

-- ============================================================================
-- LSP Server Configuration
-- ============================================================================
-- Servers are configured once with vim.lsp.config() and started with
-- vim.lsp.enable(). A FileType autocmd that also calls vim.lsp.start() would
-- spawn a second client for the same buffer (bashls#1 + bashls#2).

-- Shell script LSP (bash-language-server)
vim.lsp.config('bashls', {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh', 'bash', 'zsh' },
    root_dir = function(bufnr, on_dir)
        on_dir(buffer_root(bufnr, { '.git', 'Makefile' }))
    end,
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command)"
        }
    },
})

-- Python LSP (pylsp)
vim.lsp.config('pylsp', {
    cmd = { 'pylsp' },
    filetypes = { 'python' },
    root_dir = function(bufnr, on_dir)
        on_dir(buffer_root(bufnr, { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' }))
    end,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = false },
                flake8 = { enabled = true },
                black = { enabled = true },
            }
        }
    },
})

-- HTML LSP (superhtml). Configured, but only enabled when the binary exists.
local superhtml = vim.fn.executable('superhtml') == 1
if superhtml then
    vim.lsp.config('superhtml', {
        cmd = { 'superhtml', 'lsp' },
        filetypes = { 'html', 'shtml', 'htm' },
    })
end

-- ============================================================================
-- Enable LSP servers (configured above / in language_*.lua)
-- ============================================================================

-- ============================================================================
-- Code Formatting
-- ============================================================================

-- Manual format of the current buffer through conform.nvim (same formatters
-- as format-on-save, including the LSP fallback).
local function format_buffer(opts)
    local conform = require('conform')
    local ok, err = pcall(conform.format, vim.tbl_extend('force', {
        async = false,
        timeout_ms = 2000,
        lsp_format = 'fallback',
    }, opts or {}))
    local filetype = vim.bo.filetype
    if not ok then
        vim.notify('Format failed: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Format' })
        return
    end
    local available = conform.list_formatters_to_run(0)
    if #available == 0 and not (filetype == 'go' or filetype == 'python') then
        vim.notify('No formatter available for ' .. (filetype ~= '' and filetype or 'this buffer'),
            vim.log.levels.WARN, { title = 'Format' })
    end
end

vim.api.nvim_create_user_command("FormatCode", function()
    format_buffer()
end, {
    desc = "Format current buffer with conform.nvim",
})

snacks.keymap.set('n', '<leader>fm', function()
    format_buffer()
end, { desc = 'Format file' })

-- ============================================================================
-- LSP Keymaps
-- ============================================================================

autocmd('LspAttach', {
    callback = function(event)
        local opts = { buffer = event.buf }

        snacks.keymap.set('n', 'gD', vim.lsp.buf.definition, opts)
        snacks.keymap.set('n', 'gs', vim.lsp.buf.declaration, opts)
        snacks.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        snacks.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

        snacks.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        snacks.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

        snacks.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        snacks.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

        snacks.keymap.set('n', '<leader>nd', vim.diagnostic.goto_next, opts)
        snacks.keymap.set('n', '<leader>pd', vim.diagnostic.goto_prev, opts)
        snacks.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
        snacks.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, opts)
    end,
    desc = 'LSP keymaps',
})

-- ============================================================================
-- Diagnostic Configuration
-- ============================================================================

vim.diagnostic.config({
    virtual_text = { prefix = '●' },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
})


vim.diagnostic.config({
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
    } or {},
    virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
})

-- ============================================================================
-- Custom Commands
-- ============================================================================

vim.api.nvim_create_user_command('LspInfo', function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        vim.notify("No LSP clients attached to current buffer", vim.log.levels.WARN)
    else
        for _, client in ipairs(clients) do
            vim.notify("LSP: " .. client.name .. " (ID: " .. client.id .. ")", vim.log.levels.INFO)
        end
    end
end, { desc = 'Show LSP client info' })

-- ============================================================================
-- Enable LSP servers
-- ============================================================================

vim.lsp.enable({
    "bashls",
    "pylsp",
    -- "gopls",  -- managed by go.nvim (ray-x/go.nvim)
    "lua_ls",
    "oxlint",
    -- "rust-analyzer",  -- managed by language_rust.lua (custom clippy settings)
    "tailwindcss",
    "texlab",
    "ts_ls",
    "yamlls",
})

-- superhtml only when the binary is available (configured above)
if vim.fn.executable('superhtml') == 1 then
    vim.lsp.enable('superhtml')
end
