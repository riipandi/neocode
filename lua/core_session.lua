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

local function is_editing(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    return vim.api.nvim_win_get_config(win).relative == ""
        and vim.bo[buf].buftype == ""
        and not vim.bo[buf].filetype:match("^snacks_")
        and name ~= ""
        and vim.uv.fs_stat(name) ~= nil
end

-- The window the user was editing in: the current one, else the previous one
-- (focus may sit in the explorer when Neovim quits).
local function editing_win()
    local cur = vim.api.nvim_get_current_win()
    if is_editing(cur) then return cur end
    local prev = vim.fn.win_getid(vim.fn.winnr("#"))
    if prev ~= 0 and is_editing(prev) then return prev end
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if is_editing(win) then return win end
    end
end

-- Split layout of the editing windows only (sidebars and floats are skipped).
local function capture(node, focus)
    if node[1] == "leaf" then
        local win = node[2]
        if not is_editing(win) then return nil end
        local pos = vim.api.nvim_win_get_cursor(win)
        return {
            type = "leaf",
            file = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)),
            line = pos[1],
            col = pos[2],
            width = vim.api.nvim_win_get_width(win),
            height = vim.api.nvim_win_get_height(win),
            current = win == focus or nil,
        }
    end
    local children = {}
    for _, child in ipairs(node[2]) do
        local c = capture(child, focus)
        if c then children[#children + 1] = c end
    end
    if #children <= 1 then return children[1] end
    return { type = node[1], children = children }
end

local function snapshot()
    local focus = editing_win()
    local current = focus and vim.api.nvim_win_get_buf(focus)
    local entries = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and name ~= "" and vim.uv.fs_stat(name) then
            local pos = buf == current and vim.api.nvim_win_get_cursor(focus) or vim.api.nvim_buf_get_mark(buf, '"')
            entries[#entries + 1] = {
                file = name,
                pinned = vim.b[buf].pinned == true or nil,
                line = pos[1],
                col = pos[2],
                current = buf == current or nil,
            }
        end
    end
    return entries, capture(vim.fn.winlayout(), focus)
end

function M.save()
    local root = project_root()
    vim.fn.mkdir(dir, "p")
    local f = io.open(session_file(root), "w")
    if not f then return end
    local buffers, layout = snapshot()
    f:write(vim.json.encode({ root = root, buffers = buffers, layout = layout, columns = vim.o.columns, lines = vim.o.lines }))
    f:close()
end

local cursors = {} -- buffer -> { line, col }, applied when the buffer first loads

local function count_leaves(node)
    if node.type == "leaf" then return 1 end
    local n = 0
    for _, child in ipairs(node.children) do n = n + count_leaves(child) end
    return n
end

-- Recreate the splits in `win`, then size the leaves like they were.
local function build(node, win, leaves)
    if node.type == "leaf" then
        if not vim.uv.fs_stat(node.file) then return end
        local buf = vim.fn.bufadd(node.file)
        vim.bo[buf].buflisted = true
        vim.api.nvim_win_set_buf(win, buf)
        pcall(vim.api.nvim_win_set_cursor, win, { node.line, node.col })
        leaves[#leaves + 1] = { win = win, node = node }
        return
    end
    local wins = { win }
    for i = 2, #node.children do
        vim.api.nvim_set_current_win(wins[i - 1])
        vim.cmd(node.type == "row" and "belowright vsplit" or "belowright split")
        wins[i] = vim.api.nvim_get_current_win()
    end
    for i, child in ipairs(node.children) do
        build(child, wins[i], leaves)
    end
end

local function restore_layout(data)
    local leaves = {}
    build(data.layout, vim.api.nvim_get_current_win(), leaves)
    local sx = vim.o.columns / (data.columns or vim.o.columns)
    local sy = vim.o.lines / (data.lines or vim.o.lines)
    local focus
    for _, leaf in ipairs(leaves) do
        pcall(vim.api.nvim_win_set_width, leaf.win, math.max(math.floor(leaf.node.width * sx + 0.5), 1))
        pcall(vim.api.nvim_win_set_height, leaf.win, math.max(math.floor(leaf.node.height * sy + 0.5), 1))
        if leaf.node.current then focus = leaf.win end
    end
    if focus then vim.api.nvim_set_current_win(focus) end
end

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

    if data.layout and count_leaves(data.layout) > 1 then
        restore_layout(data)
    elseif current and vim.api.nvim_buf_get_name(0) == "" then
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
