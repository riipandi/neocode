-- ============================================================================
-- Scroll bounds: stop the viewport at the last line
-- ============================================================================
-- Every scroll key stays native (<C-e>/<C-y>, <C-d>/<C-u>, <C-f>, wheel,
-- zt/zz/zb). Only the result is corrected, so keymaps and counts are untouched.
--
-- Problem: scrolling near the end of a buffer makes Vim move the viewport into
-- the empty area below the last line and drag the cursor with it, which shows up
-- as the cursor jumping rows while the window fills with blank space.
--
-- This module is loaded *before* snacks.nvim (see init.lua) so its WinScrolled
-- handler runs first: the topline is corrected before snacks.scroll picks up the
-- new view and animates towards it. Animating towards an already-clamped target
-- is what keeps the animation smooth instead of snapping back afterwards.
--
-- The clamp yields when Vim itself demands more room than the buffer can give,
-- so the view never bounces:
--   target = max(lines that fill the window, room demanded by 'scrolloff')

local group = vim.api.nvim_create_augroup("scroll_bounds", { clear = true })

local clamping = false

--- Lowest topline Vim accepts for this view without scrolling past the end.
local function target_topline(win, buf, view)
    local height = vim.api.nvim_win_get_height(win)
    local last = vim.api.nvim_buf_line_count(buf)
    local fitted = math.max(1, last - height + 1) -- fills the window exactly
    local demanded = view.lnum - height + 1 + vim.wo[win].scrolloff
    return math.max(fitted, math.min(demanded, last))
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
    local target = target_topline(win, buf, view)
    if view.topline <= target then
        return
    end

    view.topline = target
    view.topfill = 0

    -- Skip the smooth-scroll animation for this one event: snacks.scroll would
    -- animate towards the unclamped target and then get snapped back, which is
    -- exactly the jump we are removing. The flag is restored right after, so
    -- ordinary (non-clamped) scrolling keeps animating.
    local prev = vim.b[buf].snacks_scroll
    vim.b[buf].snacks_scroll = false
    vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
            vim.b[buf].snacks_scroll = prev
        end
    end, 150)

    clamping = true
    vim.api.nvim_win_call(win, function()
        vim.fn.winrestview(view)
    end)
    clamping = false
end

vim.api.nvim_create_autocmd("WinScrolled", {
    group = group,
    callback = function()
        -- v:event is keyed by window id: { [winid] = { topline = ..., ... } }
        for win in pairs(vim.v.event) do
            local id = tonumber(win)
            if id and id > 0 then
                clamp_win(id)
            end
        end
    end,
    desc = "Keep the viewport inside the buffer",
})
