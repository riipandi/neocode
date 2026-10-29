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

local conform_util = require('conform.util')

-- oxfmt entry point.
-- vite-plus projects keep their formatter options inside vite.config.ts under
-- `fmt`. The oxfmt CLI never reads that file, so such a project would be
-- formatted with oxfmt defaults instead of its own style. `vp fmt` forwards
-- every flag to oxfmt and loads the vite config first, so those projects use
-- it; everything else keeps the plain CLI.
local vite_configs = { 'vite.config.ts', 'vite.config.js' }

local function vp_binary(ctx)
    if not ctx.dirname or ctx.dirname == '' then return nil end
    local root = vim.fs.root(ctx.dirname, vite_configs)
    if not root then return nil end
    local vp = vim.fs.joinpath(root, 'node_modules/.bin/vp')
    if vim.fn.executable(vp) == 0 then return nil end
    for _, name in ipairs(vite_configs) do
        local fd = io.open(vim.fs.joinpath(root, name), 'r')
        if fd then
            local content = fd:read('*a') or ''
            fd:close()
            if content:find('fmt%s*:') then return vp end
        end
    end
    return nil
end

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
    -- Every filetype oxfmt can parse goes through oxfmt (see `oxfmt --help`);
    -- the rest keep their own tool.
    formatters_by_ft = {
        astro = { 'oxfmt' },
        css = { 'oxfmt' },
        elixir = { 'mix' },
        graphql = { 'oxfmt' },
        -- go = { 'gofmt' },  -- handled by go.nvim (ray-x/go.nvim)
        handlebars = { 'oxfmt' },
        hcl = { 'terraform' },
        html = { 'oxfmt' },
        javascript = { 'oxfmt' },
        javascriptreact = { 'oxfmt' },
        json = { 'oxfmt' },
        json5 = { 'oxfmt' },
        jsonc = { 'oxfmt' },
        less = { 'oxfmt' },
        lit = { 'oxfmt' },
        lua = { 'stylua' },
        markdown = { 'oxfmt' },
        python = { 'black' },
        rust = { 'rustfmt' },
        scss = { 'oxfmt' },
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
        sql = { 'sql_formatter' },
        svelte = { 'oxfmt' },
        terraform = { 'terraform' },
        toml = { 'oxfmt' },
        typescript = { 'oxfmt' },
        typescriptreact = { 'oxfmt' },
        vue = { 'oxfmt' },
        yaml = { 'oxfmt' },
        zig = { 'zigfmt' },
    },
    formatters = {
        oxfmt = {
            command = function(self, ctx)
                local vp = vp_binary(ctx)
                if vp then return vp end
                return conform_util.from_node_modules('oxfmt')(self, ctx)
            end,
            args = function(_, ctx)
                local args = { '--stdin-filepath', '$FILENAME' }
                if vp_binary(ctx) then table.insert(args, 1, 'fmt') end
                return args
            end,
            cwd = conform_util.root_file({
                '.oxfmtrc.json',
                '.oxfmtrc.jsonc',
                'oxfmt.config.ts',
                'vite.config.ts',
                'vite.config.js',
            }),
            stdin = true,
        },
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
