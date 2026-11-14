vim.pack.add({
    { src = "https://github.com/saghen/blink.cmp" },
    { src = "https://github.com/saghen/blink.lib" },
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/folke/lazydev.nvim" },
    { src = "https://github.com/xzbdmw/colorful-menu.nvim" },
})

-- ============================================================================
-- Lazydev configures Lua LSP for your Neovim config, runtime and plugins
-- used for completion, annotations and signatures of Neovim apis
-- ============================================================================
require('lazydev').setup({
    library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
    },
})

-- ============================================================================
-- Configuration for Rust crates management plugin
-- ============================================================================
local dialog = require('dialog')
local CMDLINE_MENU_SHIFT = 1

require('blink.cmp').setup({
    term = { enabled = false },
    keymap = {
        preset = 'default',
        ['<Esc>'] = { 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
    },

    appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
    },

    completion = {
        list = {
            selection = { auto_insert = false }
        },
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        menu = {
            -- Search suggestions open right under the cmdline popup, left-aligned
            -- with it, instead of following the word across the screen.
            cmdline_position = function()
                local before = vim.fn.getcmdline():sub(1, vim.fn.getcmdpos() - 1)
                local word_start = #before - #before:match('[%w_%-]*$')
                local left = math.floor((vim.o.columns - (dialog.width + 2)) / 2)
                return { dialog.row + 2, left - word_start + CMDLINE_MENU_SHIFT }
            end,
        },
    },

    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
        providers = {
            lazydev = {
                module = 'lazydev.integrations.blink',
                score_offset = 100
            },
            snippets = {
                opts = {
                    friendly_snippets = true,
                    -- extended_filetypes = {
                    --   markdown = { 'jekyll' },
                    --   sh = { 'shelldoc' },
                    --   php = { 'phpdoc' },
                    --   cpp = { 'unreal' }
                    -- }
                },
            }
        },
    },

    -- snippets = { preset = 'luasnip' },
    fuzzy = {
        implementation = 'lua', -- 'lua' (default) or 'prefer_rust_with_warning'
        sorts = {
            'score',        -- Primary sort: by fuzzy matching score
            'sort_text',    -- Secondary sort: by sortText field if scores are equal
            'label',        -- Tertiary sort: by label if still tied
        }
    },
    signature = { enabled = true },
})

-- Every server gets blink's capabilities from here; language files and
-- core_lsp.lua do not repeat it.
vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

-- ============================================================================
-- Colorful-menu, bring enjoyment to your auto completion.
-- ============================================================================
require('colorful-menu').setup({
    ft = {
        lua = {
            -- Maybe you want to dim arguments a bit.
            auguments_hl = '@comment',
        },
        typescript = {
            -- Or "vtsls", their information is different, so we
            -- need to know in advance.
            ls = 'typescript-language-server',
        },
        rust = {
            -- such as (as Iterator), (use std::io).
            extra_info_hl = '@comment',
        },
        c = {
            -- such as "From <stdio.h>"
            extra_info_hl = '@comment',
        },
    },
    -- If the built-in logic fails to find a suitable highlight group,
    -- this highlight is applied to the label.
    fallback_highlight = '@variable',
    -- If provided, the plugin truncates the final displayed text to
    -- this width (measured in display cells). Any highlights that extend
    -- beyond the truncation point are ignored. Default 60.
    max_width = 60,
})

-- The menu is as wide as the cmdline popup while a cmdline is open.
do
    local menu = require('blink.cmp.completion.windows.menu')
    local group = vim.api.nvim_create_augroup('blink_cmdline_menu', { clear = true })
    vim.api.nvim_create_autocmd('CmdlineEnter', {
        group = group,
        callback = function() menu.win.config.min_width = dialog.width + 2 end,
    })
    vim.api.nvim_create_autocmd('CmdlineLeave', {
        group = group,
        callback = function() menu.win.config.min_width = 15 end,
    })
end
