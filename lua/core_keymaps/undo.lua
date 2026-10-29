-- ============================================================================
-- Undo/Redo with toast notification
-- ============================================================================
local snacks = require("snacks")

local function notify_undo()
    local count = vim.v.count > 0 and vim.v.count or nil
    local seq = vim.fn.undotree().seq_last
    local ok, err = pcall(vim.cmd, "undo" .. (count and " " .. count or ""))
    if not ok then
        -- "Already at oldest change" is a normal boundary, not a failure
        if tostring(err):match("oldest") then
            vim.notify_once("Already at oldest change", vim.log.levels.WARN, {
                title = "Undo",
                timeout = 1200,
            })
            return
        end
        vim.notify("Undo failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Undo" })
        return
    end
    local actual = seq - vim.fn.undotree().seq_last
    if actual > 0 then
        vim.notify("Undo " .. actual .. " change" .. (actual ~= 1 and "s" or ""), vim.log.levels.INFO, {
            title = "Undo",
            timeout = 1200,
        })
    else
        vim.notify_once("Already at oldest change", vim.log.levels.WARN, {
            title = "Undo",
            timeout = 1200,
        })
    end
end

local function notify_redo()
    local count = vim.v.count > 0 and vim.v.count or nil
    local seq = vim.fn.undotree().seq_last
    local ok, err = pcall(vim.cmd, "redo" .. (count and " " .. count or ""))
    if not ok then
        if tostring(err):match("newest") then
            vim.notify_once("Already at newest change", vim.log.levels.WARN, {
                title = "Redo",
                timeout = 1200,
            })
            return
        end
        vim.notify("Redo failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Redo" })
        return
    end
    local actual = vim.fn.undotree().seq_last - seq
    if actual > 0 then
        vim.notify("Redo " .. actual .. " change" .. (actual ~= 1 and "s" or ""), vim.log.levels.INFO, {
            title = "Redo",
            timeout = 1200,
        })
    else
        vim.notify_once("Already at newest change", vim.log.levels.WARN, {
            title = "Redo",
            timeout = 1200,
        })
    end
end

snacks.keymap.set("n", "u", notify_undo, { desc = "Undo with toast" })
snacks.keymap.set("n", "<C-r>", notify_redo, { desc = "Redo with toast" })

return M
