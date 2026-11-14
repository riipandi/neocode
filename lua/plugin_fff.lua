-- ============================================================================
-- fff.nvim: Fast File Search (replaces snacks.picker.files)
-- ============================================================================
-- Keeps snacks.explorer as sidebar file manager and snacks.picker for
-- buffers, commands, git status, etc.

-- Binary download on install/update
vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('fff_install', { clear = true }),
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'fff' and (kind == 'install' or kind == 'update') then
            if not ev.data.active then vim.cmd.packadd('fff') end
            require('fff.download').download_or_build_binary()
        end
    end,
})

-- ============================================================================
-- fff Setup
-- ============================================================================

pcall(function() require('fff').setup({
    lazy_sync = true,
    debug = {
        enabled = false,
        show_scores = false,
    },
    layout = {
        height = 0.78,
        width = 0.78,
        prompt_position = 'bottom',
        preview_position = 'right',
        preview_size = 0.5,
        anchor = 'center',
    },
    frecency = {
        enabled = true,
    },
    git = {
        status_text_color = true,
    },
    grep = {
        smart_case = true,
        modes = { 'plain', 'regex', 'fuzzy' },
    },
}) end)

-- ============================================================================
-- Missing native binary
-- ============================================================================
-- Keys fall back to the snacks pickers and the first use downloads the binary
-- in the background, so a fresh install or a wiped plugin dir never errors.

-- The plugin itself can be absent too (first run, install still in progress).
local function downloader()
    local ok, mod = pcall(require, 'fff.download')
    return ok and mod or nil
end

local function binary_ready()
    local dl = downloader()
    return dl ~= nil and vim.uv.fs_stat(dl.get_binary_path()) ~= nil
end

local installing = false
local function install_binary()
    local dl = downloader()
    if installing or not dl then return end
    installing = true
    vim.notify('Native binary missing, downloading it. Using the snacks picker meanwhile.',
        vim.log.levels.WARN, { title = 'fff' })
    dl.ensure_downloaded({ force = true }, function(ok, err)
        vim.schedule(function()
            if not ok then installing = false end
            if ok then
                vim.notify('Native binary installed.', vim.log.levels.INFO, { title = 'fff' })
            else
                vim.notify('Download failed: ' .. tostring(err) .. '\nRetry with :FFFHealth.',
                    vim.log.levels.ERROR, { title = 'fff' })
            end
        end)
    end)
end

local function map(lhs, desc, run, fallback)
    vim.keymap.set('n', lhs, function()
        if binary_ready() then
            local ok, err = pcall(run, require('fff'))
            if ok then return end
            vim.notify(tostring(err), vim.log.levels.ERROR, { title = 'fff' })
        else
            install_binary()
        end
        fallback()
    end, { desc = desc })
end

-- ============================================================================
-- Keymaps
-- ============================================================================

local function files() Snacks.picker.files() end
local function grep() Snacks.picker.grep() end

map('<C-o>', 'Find files (FFF)', function(fff) fff.find_files() end, files)
map('<leader><space>', 'Find files (FFF)', function(fff) fff.find_files() end, files)
map('<leader>fw', 'Live grep (FFF)', function(fff) fff.live_grep() end, grep)
map('<leader>fz', 'Live fuzzy grep (FFF)',
    function(fff) fff.live_grep({ grep = { modes = { 'fuzzy', 'plain' } } }) end, grep)
map('<leader>ff', 'Search current word (FFF)',
    function(fff) fff.live_grep({ query = vim.fn.expand('<cword>') }) end,
    function() Snacks.picker.grep_word() end)
