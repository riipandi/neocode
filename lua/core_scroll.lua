-- ============================================================================
-- Scroll bounds: stop the viewport at the last line
-- ============================================================================
-- Every scroll key stays native (<C-e>/<C-y>, <C-d>/<C-u>, <C-f>, wheel,
-- zt/zz/zb); only the result is corrected. Nothing here maps keys.
--
-- Problem: scrolling near the end of a buffer makes Vim move the viewport into
-- the empty area below the last line and drag the cursor with it (the cursor
-- appears to jump rows). `scrolloff` makes it worse: it asks for context lines
-- that cannot exist at the end of a buffer.
--
-- The correction is debounced so it never fights snacks.scroll mid-animation
-- (fighting the animation is what produces visible jitter): WinScrolled only
-- schedules a fix, the timer applies it once the scroll has settled.
--
-- The clamp yields to 'scrolloff' when it demands more room than the buffer
-- can give, so Vim does not scroll back and forth:
--   target = max(lines that fill the window, room demanded by 'scrolloff')
--
-- <S-Up>/<S-Down> are routed through <C-u>/<C-d> in core_keymaps/scroll.lua.

local uv = vim.uv or vim.loop

local group = vim.api.nvim_create_augroup("scroll_bounds", { clear = true })

local clamping = false
local pending = {}
local timer = uv.new_timer()

--- Lowest topline Vim accepts for this view without scrolling past the end.
local function target_topline(win, buf, view)
    local height = vim.api.nvim_win_get_height(win)
    local last = vim.api.nvim_buf_line_count(buf)
    local fitted = math.max(1, last - height + 1) -- fills the window exactly
    local scrolloff = vim.wo[win].scrolloff
    local demanded = view.lnum - height + 1 + scrolloff
    return math.max(fitted, math.min(demanded, last))
end

--- Drop the window-local 'scrolloff' near the end of the buffer: the context
--- margin cannot be honoured there, and honouring it is what forces the view
--- past the last line. Restored by the CursorMoved handler below.
local function sync_scrolloff(win, buf, cursor)
    local remaining = vim.api.nvim_buf_line_count(buf) - cursor
    -- vim.go: the configured value. vim.o inside this function would already
    -- report the window-local override we set ourselves.
    local want = remaining <= vim.go.scrolloff and 0 or -1 -- -1: use global
    if vim.wo[win].scrolloff ~= want then
        vim.wo[win].scrolloff = want
    end
end

local function clamp_win(win)
    if clamping or not vim.api.nvim_win_is_valid(win) then
        return
    end

    -- Regular file buffers only: skip terminals, prompts and plugin windows.
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype ~= "" then
        return
    end

    local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
    sync_scrolloff(win, buf, view.lnum)

    local target = target_topline(win, buf, view)
    if view.topline <= target then
        return
    end

    view.topline = target
    view.topfill = 0

    clamping = true
    vim.api.nvim_win_call(win, function()
        vim.fn.winrestview(view)
    end)
    clamping = false
end

local function flush()
    local wins = pending
    pending = {}
    for win in pairs(wins) do
        clamp_win(win)
    end
end

vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function()
        -- v:event is keyed by window id: { [winid] = { topline = ..., ... } }
        for win in pairs(vim.v.event) do
            local id = tonumber(win)
            if id and id > 0 then
                pending[id] = true
            end
        end

        timer:stop()
        timer:start(90, 0, function()
            vim.schedule(flush)
        end)
    end,
    desc = "Keep the viewport inside the buffer",
})

-- Bring the context margin back as soon as the cursor leaves the end region.
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    group = group,
    callback = function()
        local win = vim.api.nvim_get_current_win()
        if clamping or not vim.api.nvim_win_is_valid(win) then
            return
        end
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].buftype ~= "" then
            return
        end
        sync_scrolloff(win, buf, vim.api.nvim_win_get_cursor(win)[1])
    end,
    desc = "Restore scrolloff away from the end of the buffer",
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
        timer:stop()
        timer:close()
    end,
})
