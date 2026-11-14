-- ============================================================================
-- Core Autocommands & Editor Settings
-- ============================================================================

local snacks = require("snacks")
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- ============================================================================
-- Filetype Detection
-- ============================================================================

-- Detect Justfile; template configs (config.yml.example) are YAML
vim.filetype.add({
    filename = {
        ['Justfile'] = 'just',
        ['justfile'] = 'just',
    },
    pattern = {
        ['.*%.ya?ml%.example'] = 'yaml',
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

-- Lua uses 4 spaces (stylua.toml) unless the project's .editorconfig says
-- otherwise; the other languages keep the global 2 / ftplugin defaults.
autocmd("FileType", {
    group = user_augroup,
    pattern = "lua",
    callback = function(args)
        if vim.b[args.buf].editorconfig then
            return
        end
        vim.bo[args.buf].tabstop = 4
        vim.bo[args.buf].shiftwidth = 4
    end,
    desc = "Lua indent (4 spaces) unless .editorconfig applies",
})

-- Reload buffers changed outside Neovim (formatters, git, coding agents).
-- 'autoread' alone only reacts to an explicit :checktime.
autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
    group = user_augroup,
    callback = function()
        if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
        end
    end,
    desc = "Check for external file changes",
})

-- Terminal settings
autocmd("TermClose", {
    group = user_augroup,
    callback = function(ev)
        if vim.v.event.status == 0 and vim.api.nvim_buf_is_valid(ev.buf) then
            vim.api.nvim_buf_delete(ev.buf, { force = true })
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
        vim.opt_local.foldmethod = "manual" -- new windows inherit the treesitter fold options
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
-- Cleanup: clear nvim cache (and, with !, the plugin lock file)
-- ============================================================================
vim.api.nvim_create_user_command('CleanNvim', function(opts)
    local cache_dir = vim.fn.stdpath('cache')
    local lock_file = vim.fn.stdpath('config') .. '/nvim-pack-lock.json'
    local what = opts.bang and ('the cache and ' .. lock_file) or cache_dir
    if vim.fn.confirm('Delete ' .. what .. '?', '&Yes\n&No', 2) ~= 1 then
        return
    end

    -- Removing the lock file forgets every plugin pin (it is tracked in git)
    if opts.bang and vim.uv.fs_stat(lock_file) then
        vim.uv.fs_unlink(lock_file)
        vim.notify('Deleted: nvim-pack-lock.json', vim.log.levels.INFO)
    end

    for _, name in ipairs(vim.fn.readdir(cache_dir)) do
        vim.fn.delete(cache_dir .. '/' .. name, 'rf')
    end
    vim.notify('Cleared: ' .. cache_dir .. '. Restart Neovim to regenerate.', vim.log.levels.INFO)
end, { bang = true, desc = 'Clear the nvim cache; CleanNvim! also deletes the plugin lock file' })

-- ============================================================================
-- Plugin install/update progress notifications
-- ============================================================================
-- vim.pack default progress uses nvim_echo() which may be hidden by noice.nvim;
-- this adds visual notifications through the notifier system.
vim.api.nvim_create_autocmd('PackChangedPre', {
    group = user_augroup,
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

-- Command-line completion ('wildmenu'/'wildmode' are set in init.lua): the
-- suggestion menu opens while typing an ex command instead of waiting for <Tab>.
autocmd("CmdlineChanged", {
    group = user_augroup,
    pattern = ":",
    callback = function()
        pcall(vim.fn.wildtrigger)
    end,
    desc = "Suggest ex commands while typing",
})

vim.opt.wildignore:append({ "*.o", "*.obj", "*.pyc", "*.class", "*.jar" })

-- Diff options
vim.opt.diffopt:append("linematch:60")

-- Performance
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000
