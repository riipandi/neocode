-- ============================================================================
-- Undo/Redo with toast notification
-- ============================================================================
-- The toast keeps the shape the rest of the config uses: a short title
-- ("Undo" / "Redo") plus a body that says what happened without repeating the
-- title ("3 changes undone", not "Undo 3 changes").
local snacks = require("snacks")

local function notify_change(direction)
    local undo = direction == "undo"
    local title = undo and "Undo" or "Redo"
    -- Past participle for the body text
    local done = undo and "undone" or "redone"
    -- Undo stops at the oldest change, redo at the newest one
    local boundary = undo and "oldest" or "newest"

    -- seq_cur is the position in the undo tree; seq_last only grows, so it
    -- cannot tell how far an undo or redo actually moved.
    local seq = vim.fn.undotree().seq_cur
    local count = vim.v.count > 0 and vim.v.count or nil
    local ok, err = pcall(vim.cmd, direction .. (count and " " .. count or ""))
    if not ok then
        -- A boundary is a normal end of the history, not a failure
        if tostring(err):match(boundary) then
            vim.notify_once("Already at " .. boundary .. " change", vim.log.levels.WARN, {
                title = title,
                timeout = 1200,
            })
            return
        end
        vim.notify("Failed: " .. tostring(err), vim.log.levels.ERROR, { title = title })
        return
    end

    local moved = undo and (seq - vim.fn.undotree().seq_cur) or (vim.fn.undotree().seq_cur - seq)
    if moved > 0 then
        vim.notify(moved .. " change" .. (moved ~= 1 and "s" or "") .. " " .. done, vim.log.levels.INFO, {
            title = title,
            timeout = 1200,
        })
        return
    end

    vim.notify_once("Already at " .. boundary .. " change", vim.log.levels.WARN, {
        title = title,
        timeout = 1200,
    })
end

snacks.keymap.set("n", "u", function() notify_change("undo") end, { desc = "Undo with toast" })
snacks.keymap.set("n", "<C-r>", function() notify_change("redo") end, { desc = "Redo with toast" })
