-- ============================================================================
-- Scroll behaviour: bounded, symmetric, animated
-- ============================================================================
-- Goals:
--   1. never scroll past the last line (the area below EOF stays unreachable)
--   2. every scroll key behaves the same way in both directions
--   3. keyboard and mouse go through the same path, so snacks.scroll animates
--      them identically
--
-- Notes on the native bindings this replaces:
--   * <C-Down> scrolled the viewport while <C-Up> only moved the cursor
--   * <S-Up>/<S-Down> are page up/down, i.e. four times the movement of
--     <C-u>/<C-d>, which made the two half-page keys feel unrelated
--     (Shift+Arrows keep their native "extend selection" action in visual mode)

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

local function apply(lhs, builtin, desc, direction, modes)
    for _, mode in ipairs(modes) do
        vim.keymap.set(mode, lhs, function()
            if direction == "down" then
                scroll_down(builtin)
            else
                scroll(builtin)
            end
        end, { desc = desc })
    end
end

local normal_and_visual = { "n", "x" }

-- one line, symmetric in both directions
apply("<C-e>", "<C-e>", "Scroll down one line", "down", normal_and_visual)
apply("<C-y>", "<C-y>", "Scroll up one line", "up", normal_and_visual)
apply("<C-Down>", "<C-e>", "Scroll down one line", "down", normal_and_visual)
apply("<C-Up>", "<C-y>", "Scroll up one line", "up", normal_and_visual)

-- half page (native cursor movement kept, only the view is bounded)
apply("<C-d>", "<C-d>", "Half page down (stops at end of buffer)", "down", normal_and_visual)
apply("<C-u>", "<C-u>", "Half page up", "up", normal_and_visual)

-- Shift+Arrows: same half-page movement as <C-d>/<C-u> instead of a full page.
-- Normal mode only: in visual mode they must keep extending the selection.
apply("<S-Down>", "<C-d>", "Half page down (stops at end of buffer)", "down", { "n" })
apply("<S-Up>", "<C-u>", "Half page up", "up", { "n" })

-- full page
apply("<C-f>", "<C-f>", "Page down (stops at end of buffer)", "down", normal_and_visual)

-- mouse wheel
apply("<ScrollWheelDown>", "<ScrollWheelDown>", "Scroll down (stops at end of buffer)", "down",
    normal_and_visual)
apply("<ScrollWheelUp>", "<ScrollWheelUp>", "Scroll up", "up", normal_and_visual)
