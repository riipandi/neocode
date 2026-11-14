-- ============================================================================
-- Dim inactive splits
-- ============================================================================
-- Every highlight group with a foreground gets a `<Group>NC` twin whose colour
-- is blended towards the background; inactive editing windows map the whole
-- set through 'winhighlight'. Focus on the sidebar, a picker or a float leaves
-- the dimming as it is.
local STRENGTH = 0.45 -- how far colours move towards the background (0..1)

local winhl = ""

local function blend(fg, bg)
    local function ch(shift)
        local f, b = bit.band(bit.rshift(fg, shift), 0xff), bit.band(bit.rshift(bg, shift), 0xff)
        return math.floor(f + (b - f) * STRENGTH + 0.5)
    end
    return ch(16) * 0x10000 + ch(8) * 0x100 + ch(0)
end

local function build()
    local bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg or 0x181a1d
    local map = {}
    for name, def in pairs(vim.api.nvim_get_hl(0, {})) do
        local real = vim.api.nvim_get_hl(0, { name = name, link = false })
        if real.fg and not name:match("NC$") and not name:find("[,:]") then
            real.fg = blend(real.fg, bg)
            vim.api.nvim_set_hl(0, name .. "NC", real)
            map[#map + 1] = name .. ":" .. name .. "NC"
        end
    end
    winhl = table.concat(map, ",")
end

local function editing(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.api.nvim_win_get_config(win).relative == ""
        and vim.bo[buf].buftype == ""
        and vim.bo[buf].buflisted
        and not vim.bo[buf].filetype:match("^snacks_")
end

local function refresh()
    local cur = vim.api.nvim_get_current_win()
    if not editing(cur) then return end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if editing(win) then vim.wo[win].winhighlight = win == cur and "" or winhl end
    end
end

-- Deferred: a sidebar opens as a split that briefly shows the current buffer,
-- and judging the windows at that moment would dim the real editing window.
local pending = false
local function refresh_soon()
    if pending then return end
    pending = true
    vim.schedule(function()
        pending = false
        refresh()
    end)
end

local group = vim.api.nvim_create_augroup("dim_inactive", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = function() build(); refresh() end })
vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
        build()
        refresh_soon()
    end,
})
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, { group = group, callback = refresh_soon })
