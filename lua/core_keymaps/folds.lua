-- ============================================================================
-- Folds: smart toggle on <S-CR>
-- ============================================================================
-- `za` alone only works when the cursor sits on a foldable line; on a top-level
-- row it aborts with "E490: No fold found" (14 of the first 60 rows in a lua
-- file), which is what made Shift+Enter feel broken.
--
-- Rules:
--   1. cursor inside a closed fold      -> open it
--   2. cursor on a foldable line        -> close the innermost fold
--   3. cursor on a top-level line       -> fold the nearest block below (cursor
--                                          stays where it was), else above
--   4. nothing foldable in the buffer   -> tell the user instead of erroring
--
-- Folds come from `foldmethod=expr` with the treesitter foldexpr, so a "block"
-- is the syntax block: function, table, object, markdown section, ...

local M = {}

local function foldlevel(row)
    if row < 1 then
        return 0
    end
    return vim.fn.foldlevel(row)
end

--- First row in `direction` (+1/-1) that starts a fold.
local function nearest_fold_start(lnum, last, direction)
    local row = lnum + direction
    while row >= 1 and row <= last do
        local level = foldlevel(row)
        if level > 0 and foldlevel(row - 1) < level then
            return row
        end
        row = row + direction
    end
end

function M.toggle()
    local win = 0
    local cursor = vim.api.nvim_win_get_cursor(win)
    local lnum = cursor[1]

    -- 1. inside a closed fold: open it
    if vim.fn.foldclosed(lnum) ~= -1 then
        vim.cmd("normal! zo")
        return
    end

    -- 2. foldable line: close the innermost fold around it
    if foldlevel(lnum) > 0 then
        vim.cmd("normal! zc")
        return
    end

    -- 3. top-level line: fold the closest block, keeping the cursor in place
    local last = vim.api.nvim_buf_line_count(0)
    local target = nearest_fold_start(lnum, last, 1) or nearest_fold_start(lnum, last, -1)
    if not target then
        vim.notify("Nothing to fold here", vim.log.levels.INFO, { title = "Folds" })
        return
    end

    -- zo/zc act on the fold under the cursor, so move there first and put the
    -- cursor back afterwards (the original row cannot be inside a fold here,
    -- its foldlevel is 0).
    vim.api.nvim_win_set_cursor(win, { target, 0 })
    if vim.fn.foldclosed(target) ~= -1 then
        vim.cmd("normal! zo")
    else
        vim.cmd("normal! zc")
    end
    vim.api.nvim_win_set_cursor(win, cursor)
end

return M
