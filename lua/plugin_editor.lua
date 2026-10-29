-- ============================================================================
-- Editor Enhancement Plugins
-- ============================================================================

vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/folke/todo-comments.nvim" },
    { src = "https://github.com/axieax/urlview.nvim" },
    { src = "https://github.com/laytan/cloak.nvim" },
    { src = "https://github.com/stevearc/conform.nvim" },
})

-- Note: Indentation guides are handled by snacks.indent (see core_plugins.lua)

-- ============================================================================
-- Auto-pairs: Automatically close brackets, quotes, etc.
-- ============================================================================

require('nvim-autopairs').setup({
    enabled = function(bufnr) return true end,
    disable_filetype = { "spectre_panel", "snacks_picker_input" },
    disable_in_macro = true,
    disable_in_visualblock = false,
    disable_in_replace_mode = true,
    ignored_next_char = [=[[%w%%%'%[%-%."`%$]]=],
    enable_moveright = true,
    enable_afterquote = true,
    enable_check_bracket_line = true,
    enable_bracket_in_quote = true,
    enable_abbr = false,
    break_undo = true,
    check_ts = false,
    map_cr = true,
    map_bs = true,
    map_c_h = false,
    map_c_w = false,
})

-- ============================================================================
-- Todo Comments: Highlight TODO, NOTE, FIX, etc. in comments
-- ============================================================================

require('todo-comments').setup({
    signs = false
})

-- ============================================================================
-- URL View: Extract and open URLs from buffer
-- ============================================================================

require('urlview').setup({
    default_title = "Links:",
    default_picker = "default",
    default_prefix = "https://",
    default_action = "system",
    log_level_min = vim.log.levels.INFO,
})

-- ============================================================================
-- Cloak: Hide sensitive information in .env files
-- ============================================================================

require('cloak').setup({
    enabled = true,
    cloak_character = '*',
    highlight_group = 'Comment',
    cloak_length = 12,
    try_all_patterns = true,
    patterns = {
        {
            file_pattern = '.env*',
            cloak_pattern = '=.+',
        },
    },
})

-- ============================================================================
-- Conform: Code formatter with LSP integration
-- ============================================================================

require('conform').setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] or vim.b[bufnr].disable_autoformat then
            return nil
        else
            return {
                timeout_ms = 500,
                lsp_format = 'fallback',
            }
        end
    end,
    -- Note: a plain list runs every formatter; `stop_after_first` makes it a
    -- fallback chain. The nested `{ { "a", "b" } }` form is rejected by
    -- conform and aborts BufWritePre (i.e. the file is never written).
    -- Oxc-only: oxlint lints and oxfmt formats. prettier, prettierd, eslint and
    -- biome are deliberately absent, so nothing competes with the oxc tools.
    formatters_by_ft = {
        astro = { 'oxfmt' },
        elixir = { 'mix' },
        -- go = { 'gofmt' },  -- handled by go.nvim (ray-x/go.nvim)
        hcl = { 'terraform' },
        javascript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        json = { 'oxfmt' },
        lit = { 'oxfmt' },
        lua = { 'stylua' },
        python = { 'black' },
        rust = { 'rustfmt' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        svelte = { 'oxfmt' },
        sql = { 'sql_formatter' },
        terraform = { 'terraform' },
        typescript = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        vue = { 'oxfmt' },
        zig = { 'zigfmt' },
    },
    formatters = {
        mix = {
            command = 'mix',
            args = { 'format', '--stdin-filename', '$FILENAME' },
            stdin = true,
        },
        terraform = {
            command = 'terraform',
            args = { 'fmt', '-' },
            stdin = true,
        },
    },
})
