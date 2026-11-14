-- Bursts of install notifications (Mason, vim.pack) become one toast per source
-- that updates in place and shows the latest lines. Errors get their own toast
-- so they are not buried; everything else passes through untouched.
-- snacks installs a one-shot vim.notify stub that overwrites vim.notify on first
-- use, so forward to the notifier directly instead of keeping the old function.
local function base(...) return Snacks.notifier.notify(...) end
local MAX_LINES = 6
local IDLE_MS = 6000

local function title_is(name)
    return function(_, opts) return opts and opts.title == name end
end

local GROUPS = {
    { name = "mason-tool-installer", match = title_is("mason-tool-installer") },
    { name = "mason.nvim", match = title_is("mason.nvim") },
    { name = "Plugins", match = title_is("Plugins") },
}

-- Untitled toasts would render an empty title bar next to the titled ones.
local DEFAULT_TITLE = {
    [vim.log.levels.ERROR] = "Error",
    [vim.log.levels.WARN] = "Warning",
}

local state = {} -- toast id -> { lines, timer }

local function push(group, msg, level)
    local id = group.name .. (level >= vim.log.levels.ERROR and " errors" or "")
    local s = state[id]
    if not s then
        s = { lines = {}, timer = vim.uv.new_timer() }
        state[id] = s
    end

    local line = msg
    if s.lines[#s.lines] ~= line then
        s.lines[#s.lines + 1] = line
    end

    local text = table.concat(vim.list_slice(s.lines, math.max(1, #s.lines - MAX_LINES + 1)), "\n")
    if #s.lines > MAX_LINES then
        text = ("… %d more above\n"):format(#s.lines - MAX_LINES) .. text
    end
    base(text, level, { title = group.name, id = "group_" .. id })

    s.timer:stop()
    s.timer:start(IDLE_MS, 0, function() s.lines = {} end)
end

vim.notify = function(msg, level, opts)
    level = level or vim.log.levels.INFO
    msg = tostring(msg)
    for _, group in ipairs(GROUPS) do
        if group.match(msg, opts) then
            return push(group, msg, level)
        end
    end
    if not (opts and opts.title) then
        opts = vim.tbl_extend("force", opts or {}, { title = DEFAULT_TITLE[level] or "Info" })
    end
    return base(msg, level, opts)
end
