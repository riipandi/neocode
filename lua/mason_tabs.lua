-- [ ] and <Left> <Right> cycle the tabs of the :Mason window (All, LSP, DAP, Linter,
-- Formatter) as an alternative to the number keys. Mason does not expose the
-- active tab, so it is read back from the highlight on the tab line.
local M = {}

local TABS = 5
local ACTIVE = { MasonHighlightBlockBold = true, MasonHighlightBlockBoldSecondary = true }

function M.current(buf)
    for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, 20, false)) do
        if line:find("(1) All", 1, true) then
            local marks = vim.api.nvim_buf_get_extmarks(buf, -1, { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true })
            for _, m in ipairs(marks) do
                local d = m[4]
                if ACTIVE[d.hl_group] then
                    local idx = line:sub(m[3] + 1, d.end_col):match("%((%d)%)")
                    if idx then return tonumber(idx) end
                end
            end
        end
    end
    return 1
end

local function step(buf, delta)
    local target = (M.current(buf) - 1 + delta) % TABS + 1
    vim.api.nvim_feedkeys(tostring(target), "m", false)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("mason_tabs", { clear = true }),
    pattern = "mason",
    callback = function(ev)
        local opts = { buffer = ev.buf, nowait = true, silent = true }
        vim.keymap.set("n", "]", function() step(ev.buf, 1) end, vim.tbl_extend("force", opts, { desc = "Next Mason tab" }))
        vim.keymap.set("n", "[", function() step(ev.buf, -1) end, vim.tbl_extend("force", opts, { desc = "Previous Mason tab" }))
        vim.keymap.set("n", "<Right>", function() step(ev.buf, 1) end, vim.tbl_extend("force", opts, { desc = "Next Mason tab" }))
        vim.keymap.set("n", "<Left>", function() step(ev.buf, -1) end, vim.tbl_extend("force", opts, { desc = "Previous Mason tab" }))
    end,
})

return M
