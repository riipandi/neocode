-- ============================================================================
-- Scroll behaviour: bounded, symmetric, animated
-- ============================================================================
-- Goals:
--   1. never scroll past the last line (the area below EOF stays unreachable)
--   2. every scroll direction behaves the same way (native <C-Down> scrolled the
--      viewport while <C-Up> only moved the cursor)
--   3. keyboard and mouse go through the same path, so snacks.scroll animates
--      them identically

local function feed(keys)
    -- "nx": execute immediately without remapping (a bare "x" remaps and
    -- recurses into these mappings).
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

-- Highest topline that still fills the window with buffer lines.
local function max_topline()
    local height = vim.api.nvim_win_get_height(0)
    local last = vim.fn.line("$")
    return math.max(1, last - height + 1)
end

local function clamp()
    local max_top = max_topline()
    if vim.fn.line("w0") <= max_top then
        return
    end
    local view = vim.fn.winsaveview()
    view.topline = max_top
    view.topfill = 0
    vim.fn.winrestview(view)
end

--- Run a scroll builtin and clamp the result so the viewport stops at EOF.
local function scroll(keys)
    feed(keys)
    clamp()
end

--- Scroll down only when there is still content below the cursor.
local function scroll_down(keys)
    if vim.fn.line("w0") >= max_topline() then
        return
    end
    scroll(keys)
end

local keys = {
    -- one line, symmetric in both directions
    { "<C-e>", "<C-e>", "Scroll down one line", "down" },
    { "<C-y>", "<C-y>", "Scroll up one line", "up" },
    -- ctrl+arrows: same as <C-e>/<C-y> (one line) instead of the asymmetric
    -- native behaviour
    { "<C-Down>", "<C-e>", "Scroll down one line", "down" },
    { "<C-Up>", "<C-y>", "Scroll up one line", "up" },
    -- half page (keeps the native cursor movement, only the view is bounded)
    { "<C-d>", "<C-d>", "Half page down (stops at end of buffer)", "down" },
    { "<C-u>", "<C-u>", "Half page up", "up" },
    -- full page
    { "<C-f>", "<C-f>", "Page down (stops at end of buffer)", "down" },
    -- mouse wheel
    { "<ScrollWheelDown>", "<ScrollWheelDown>", "Scroll down (stops at end of buffer)", "down" },
    { "<ScrollWheelUp>", "<ScrollWheelUp>", "Scroll up", "up" },
}

for _, spec in ipairs(keys) do
    local lhs, builtin, desc, direction = spec[1], spec[2], spec[3], spec[4]
    for _, mode in ipairs({ "n", "x" }) do
        vim.keymap.set(mode, lhs, function()
            if direction == "down" then
                scroll_down(builtin)
            else
                scroll(builtin)
            end
        end, { desc = desc })
    end
end
