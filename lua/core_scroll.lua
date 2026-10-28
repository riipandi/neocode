-- ============================================================================
-- Scroll bounds: never scroll past the last line
-- ============================================================================
-- Vim allows <C-e> (and <C-f>, mouse wheel) to keep scrolling until the last
-- line sits at the top of the window. The empty area below EOF then looks like
-- the buffer continues past its last line (invisible here because `eob` is
-- rendered as a blank). Clamp those keys so the view stops as soon as the last
-- line reaches the bottom of the window.

local function feed(keys)
    -- "nx": execute immediately without remapping (a bare "x" would remap and
    -- recurse into this mapping).
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

-- Scroll down one line, but stop at the end of the buffer.
local function scroll_down(keys)
    if vim.fn.line("w0") >= max_topline() then
        return
    end
    feed(keys)
    clamp()
end

for _, mode in ipairs({ "n", "x" }) do
    vim.keymap.set(mode, "<C-e>", function()
        scroll_down("<C-e>")
    end, { desc = "Scroll down (stops at end of buffer)" })

    vim.keymap.set(mode, "<C-f>", function()
        scroll_down("<C-f>")
    end, { desc = "Page down (stops at end of buffer)" })
end

for _, mode in ipairs({ "n", "x" }) do
    -- Mouse wheel: same rule, but the wheel may move several lines at once.
    vim.keymap.set(mode, "<ScrollWheelDown>", function()
        scroll_down("<ScrollWheelDown>")
    end, { desc = "Scroll down (stops at end of buffer)" })
end
