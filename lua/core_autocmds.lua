-- ============================================================================
-- Core Autocommands & Editor Settings
-- ============================================================================

local snacks = require("snacks")
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- Filetype Detection
-- ============================================================================

-- Detect Justfile
vim.filetype.add({
    filename = {
        ['Justfile'] = 'just',
        ['justfile'] = 'just',
    },
})

-- ============================================================================
-- Keymaps
-- ============================================================================

-- Copy full file path to clipboard
snacks.keymap.set("n", "<leader>pa", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify("file: " .. path, vim.log.levels.INFO)
end, { desc = "Copy full file path" })

-- ============================================================================
-- Autocommands
-- ============================================================================

local user_augroup = augroup("UserConfig", { clear = true })

-- (search toast moved to <CR> mapping in core_keymaps.lua)


-- Highlight yanked text briefly
autocmd("TextYankPost", {
    group = user_augroup,
    callback = function()
        vim.hl.on_yank()
    end,
    desc = "Highlight yanked text",
})

-- Return to last edit position when opening files
autocmd("BufReadPost", {
    group = user_augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
    desc = "Restore cursor position",
})

-- Filetype-specific settings
autocmd("FileType", {
    group = user_augroup,
    pattern = { "lua", "python" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
    desc = "Set indent to 4 spaces for lua/python",
})

autocmd("FileType", {
    group = user_augroup,
    pattern = { "javascript", "typescript", "json", "html", "css" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
    desc = "Set indent to 2 spaces for web/js",
})

autocmd("FileType", {
    group = user_augroup,
    callback = function()
        vim.b.autoformat = false
    end,
    desc = "Disable autoformat for toml",
})

-- Terminal settings
autocmd("TermClose", {
    group = user_augroup,
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
    desc = "Auto-close terminal on exit",
})

autocmd("TermOpen", {
    group = user_augroup,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
    desc = "Disable line numbers in terminal",
})

-- Window management
autocmd("VimResized", {
    group = user_augroup,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
    desc = "Equalize splits on resize",
})

-- File operations
autocmd("BufWritePre", {
    group = user_augroup,
    callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, 'p')
        end
    end,
    desc = "Create directories on save",
})

-- ============================================================================
-- Cleanup: clear nvim cache and reset lock file
-- ============================================================================
vim.api.nvim_create_user_command('CleanNvim', function()
    local config_dir = vim.fn.stdpath('config')
    local cache_dir = vim.fn.stdpath('cache')
    local lock_file = config_dir .. '/nvim-pack-lock.json'

    -- Remove lock file to force plugin re-pinning
    local lock_stat = vim.uv.fs_stat(lock_file)
    if lock_stat then
        vim.uv.fs_unlink(lock_file)
        vim.notify('Deleted: nvim-pack-lock.json', vim.log.levels.INFO)
    end

    -- Clean nvim cache
    for _, name in ipairs(vim.fn.readdir(cache_dir)) do
        vim.fn.delete(cache_dir .. '/' .. name, 'rf')
    end
    vim.notify('Cleared: ' .. cache_dir, vim.log.levels.INFO)

    vim.notify('Done. Restart Neovim to regenerate.', vim.log.levels.INFO)
end, { desc = 'Clean nvim cache and reset lock file' })

-- ============================================================================
-- Plugin install/update progress notifications
-- ============================================================================
-- vim.pack default progress uses nvim_echo() which may be hidden by noice.nvim;
-- this adds visual notifications through the notifier system.
vim.api.nvim_create_autocmd('PackChangedPre', {
    callback = function(ev)
        local kind = ev.data.kind
        local name = ev.data.spec.name
        local msg = ('vim.pack: %s %s'):format(kind, name)
        vim.notify(msg, vim.log.levels.INFO, { title = 'Plugins' })
    end,
    desc = 'Notify plugin install/update progress',
})

-- ============================================================================
-- Editor Settings
-- ============================================================================
-- ============================================================================

-- Command-line completion
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Diff options
vim.opt.diffopt:append("linematch:60")

-- Performance
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Create undo directory if not exists
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, "p")
end
