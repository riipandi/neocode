-- ============================================================================
-- Session: reopen a project's buffers and pins
-- ============================================================================
-- One file per project (the git root of the start directory, else the
-- directory itself) under stdpath("state")/sessions. Only a start without file
-- arguments restores and saves, so `nvim some/file` never overwrites a session.
local M = {}

local dir = vim.fn.stdpath("state") .. "/sessions"

local function project_root()
    local start = vim.fn.getcwd()
    if vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
        start = vim.fn.fnamemodify(vim.fn.argv(0), ":p")
    end
    return vim.fs.root(start, ".git") or vim.fs.normalize(start)
end

local function session_file(root)
    return ("%s/%s-%s.json"):format(dir, vim.fn.fnamemodify(root, ":t"), vim.fn.sha256(root):sub(1, 12))
end

local function only_dir_or_empty_args()
    return vim.fn.argc() == 0 or (vim.fn.argc() == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1)
end

local function snapshot()
    local current = vim.api.nvim_get_current_buf()
    local entries = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and name ~= "" and vim.uv.fs_stat(name) then
            local pos = buf == current and vim.api.nvim_win_get_cursor(0) or vim.api.nvim_buf_get_mark(buf, '"')
            entries[#entries + 1] = {
                file = name,
                pinned = vim.b[buf].pinned == true or nil,
                line = pos[1],
                col = pos[2],
                current = buf == current or nil,
            }
        end
    end
    return entries
end

function M.save()
    local root = project_root()
    vim.fn.mkdir(dir, "p")
    local f = io.open(session_file(root), "w")
    if not f then return end
    f:write(vim.json.encode({ root = root, buffers = snapshot() }))
    f:close()
end

local cursors = {} -- buffer -> { line, col }, applied when the buffer first loads

function M.restore()
    local f = io.open(session_file(project_root()), "r")
    if not f then return end
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    if not ok or type(data) ~= "table" or type(data.buffers) ~= "table" then return end

    local count, current = 0, nil
    for _, e in ipairs(data.buffers) do
        if vim.uv.fs_stat(e.file) then
            local buf = vim.fn.bufadd(e.file)
            vim.bo[buf].buflisted = true
            vim.b[buf].pinned = e.pinned or nil
            if e.line and e.line > 0 then
                cursors[buf] = { e.line, e.col or 0 }
            end
            if e.current then current = buf end
            count = count + 1
        end
    end
    if count == 0 then return end

    if current and vim.api.nvim_buf_get_name(0) == "" then
        vim.api.nvim_set_current_buf(current)
    end
    vim.notify(("Restored %d buffer%s"):format(count, count == 1 and "" or "s"), vim.log.levels.INFO, { title = "Session" })
end

function M.clear()
    vim.fn.delete(session_file(project_root()))
    vim.notify("Session cleared for " .. project_root(), vim.log.levels.INFO, { title = "Session" })
end

local group = vim.api.nvim_create_augroup("session", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    nested = true,
    callback = function()
        if only_dir_or_empty_args() then
            vim.g.session_active = true
            M.restore()
        end
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function(ev)
        local pos = cursors[ev.buf]
        cursors[ev.buf] = nil
        if pos and vim.api.nvim_win_get_buf(0) == ev.buf then
            pcall(vim.api.nvim_win_set_cursor, 0, pos)
        end
    end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
        if vim.g.session_active then M.save() end
    end,
})

vim.api.nvim_create_user_command("SessionClear", M.clear, { desc = "Forget this project's saved buffers and pins" })

return M
