-- ============================================================================
-- Scroll bounds: stop the viewport at the last line
-- ============================================================================
-- Every scroll key stays native (<C-e>/<C-y>, <C-d>/<C-u>, zt/zz/zb); only the
-- result is corrected. The wheel is native too, except for its last notch.
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
--   target = max(rows that fill the window, room demanded by 'scrolloff')

local M = {}

local group = vim.api.nvim_create_augroup("scroll_bounds", { clear = true })

local clamping = false

--- Lowest topline whose rows up to `last` fit in `rows` screen rows. Counts
--- screen rows (wrap, folds, virtual lines), not buffer lines.
local function topline_for(win, last, rows)
    local lo, hi = 1, last
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        local text = vim.api.nvim_win_text_height(win, { start_row = mid - 1, end_row = last - 1 })
        if text.all <= rows then
            hi = mid
        else
            lo = mid + 1
        end
    end
    return lo
end

--- Lowest topline Vim accepts for this view without scrolling past the end.
local function target_topline(win, buf, view)
    local height = vim.api.nvim_win_get_height(win)
    local last = vim.api.nvim_buf_line_count(buf)
    local fitted = topline_for(win, last, height) -- fills the window exactly
    local demanded = topline_for(win, view.lnum, height - vim.wo[win].scrolloff)
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

-- The wheel is the one input that overshoots: a notch scrolls
-- 'mousescroll' lines, so the last notch crosses the end, drags the cursor
-- down with the overshoot and only then gets clamped. Stop it at the last
-- line instead, and let the cursor stay where it is.
local function wheel_down()
    local win = vim.fn.getmousepos().winid
    if not vim.api.nvim_win_is_valid(win) then
        return ""
    end
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype ~= "" then
        return "<ScrollWheelDown>"
    end

    local view = vim.api.nvim_win_call(win, vim.fn.winsaveview)
    local room = target_topline(win, buf, view) - view.topline
    local step = tonumber(vim.o.mousescroll:match("ver:(%d+)")) or 3
    if room >= step then
        return "<ScrollWheelDown>"
    end
    if room > 0 then
        -- an <expr> mapping cannot switch windows; <Cmd> runs in key order
        return ("<Cmd>lua require('core_scroll').scroll(%d, %d)<CR>"):format(win, room)
    end
    return ""
end

function M.scroll(win, lines)
    if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, function()
            vim.cmd(("normal! %d\5"):format(lines))
        end)
    end
end

vim.keymap.set({ "n", "x", "i" }, "<ScrollWheelDown>", wheel_down, { expr = true, desc = "Wheel down, stops at the last line" })

-- Scrolling up is done by hand. Native scrolling decides whether the cursor is
-- still on screen without counting the virtual lines render-markdown adds
-- (table borders), so the view went up, left the cursor behind and was then
-- pushed back down: the wheel stalled in the middle of the file.
local function wheel_up()
    local win = vim.fn.getmousepos().winid
    if not vim.api.nvim_win_is_valid(win) or vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "" then
        return "<ScrollWheelUp>"
    end
    local step = tonumber(vim.o.mousescroll:match("ver:(%d+)")) or 3
    return ("<Cmd>lua require('core_scroll').up(%d, %d)<CR>"):format(win, step)
end

--- Largest line in [top, max] whose rows from `top` still fit in `rows`.
local function bottom_for(win, top, max, rows)
    local lo, hi = top, max
    while lo < hi do
        local mid = math.ceil((lo + hi) / 2)
        local text = vim.api.nvim_win_text_height(win, { start_row = top - 1, end_row = mid - 1 })
        if text.all <= rows then
            lo = mid
        else
            hi = mid - 1
        end
    end
    return lo
end

function M.up(win, lines)
    if not vim.api.nvim_win_is_valid(win) then
        return
    end
    vim.api.nvim_win_call(win, function()
        local view = vim.fn.winsaveview()
        local top = math.max(1, view.topline - lines)
        if top == view.topline then
            return
        end
        -- the cursor follows only when it would fall off the bottom
        local rows = vim.api.nvim_win_get_height(win) - vim.wo[win].scrolloff
        view.lnum = bottom_for(win, top, view.lnum, rows)
        view.topline, view.topfill = top, 0
        vim.fn.winrestview(view)
    end)
end

vim.keymap.set({ "n", "x", "i" }, "<ScrollWheelUp>", wheel_up, { expr = true, desc = "Wheel up, keeps the cursor in view" })

-- Picker lists (file explorer) scroll their own virtual viewport. Their wheel
-- handler also drags the cursor along once the end is reached; keep the cursor
-- where it is, as in an editor window.
local wheel_until = 0 -- ns: the list scrolls from a scheduled callback shortly after the key
local list_patched = false

local function patch_list()
    if list_patched then
        return
    end
    list_patched = true
    local List = require("snacks.picker.core.list")
    local scroll = List._scroll
    function List:_scroll(to, absolute, render)
        if absolute or vim.uv.hrtime() > wheel_until then
            return scroll(self, to, absolute, render)
        end
        local room = to > 0 and (self:count() - self:height() + 1 - self.top) or (1 - self.top)
        to = to > 0 and math.min(to, math.max(room, 0)) or math.max(to, math.min(room, 0))
        local cursor = self.cursor
        scroll(self, to, absolute, false)
        self.cursor = math.max(self.top, math.min(cursor, self.top + self:height() - 1))
        if render ~= false then
            self:render()
        end
    end
end

vim.on_key(function(key, typed)
    key = vim.fn.keytrans(typed ~= "" and typed or key)
    if key ~= "<ScrollWheelUp>" and key ~= "<ScrollWheelDown>" then
        return
    end
    local win = vim.fn.getmousepos().winid
    if win > 0 and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "snacks_picker_list" then
        patch_list()
        wheel_until = vim.uv.hrtime() + 100e6
    end
end, vim.api.nvim_create_namespace("scroll_bounds"))

return M
