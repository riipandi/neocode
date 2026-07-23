-- ============================================================================
-- Version Control Plugins
-- ============================================================================

-- Note: LazyGit integration is handled by snacks.lazygit (see core_plugins.lua)

vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
})

local snacks = require("snacks")

-- ============================================================================
-- Git Signs: Git integration in gutter & hunk management
-- ============================================================================

require('gitsigns').setup({
    signcolumn = true,
    signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            snacks.keymap.set(mode, l, r, opts)
        end

        -- Navigation between hunks
        map('n', ']c', function()
            if vim.wo.diff then
                vim.cmd.normal { ']c', bang = true }
            else
                gitsigns.nav_hunk 'next'
            end
        end, { desc = 'Git: Next hunk' })

        map('n', '[c', function()
            if vim.wo.diff then
                vim.cmd.normal { '[c', bang = true }
            else
                gitsigns.nav_hunk 'prev'
            end
        end, { desc = 'Git: Previous hunk' })

        -- Hunk actions (visual mode)
        map('v', '<leader>hs', function()
            gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Git: Stage hunk' })
        map('v', '<leader>hr', function()
            gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Git: Reset hunk' })

        -- Hunk actions (normal mode)
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git: Stage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git: Reset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git: Stage buffer' })
        map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'Git: Undo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git: Reset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git: Preview hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git: Blame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git: Diff against index' })
        map('n', '<leader>hD', function()
            gitsigns.diffthis '@'
        end, { desc = 'Git: Diff against last commit' })

        -- Toggle commands
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Git: Toggle blame' })
        map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = 'Git: Toggle deleted' })
    end,
})

-- ============================================================================
-- Git Commands
-- ============================================================================

snacks.keymap.set("n", "<leader>gp", '<cmd>Git push<CR>', { desc = "Git: Push" })
