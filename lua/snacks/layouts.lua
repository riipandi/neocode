-- ============================================================================
-- Snacks Picker Layouts
-- ============================================================================
-- Custom layout definitions for the snacks.picker.
-- These are referenced by name in snacks.setup via picker.layouts.<name>.
-- ============================================================================
local M = {}

local dialog = require("dialog")

-- Single column, search field at the bottom: confirmations (vim.ui.select)
-- and palettes. Palettes share
-- the width and row of the input dialogs and the cmdline popup.
local function column(height)
    return {
        layout = {
            backdrop = false,
            box = "vertical",
            width = dialog.width + 2,
            row = dialog.row,
            height = height,
            min_height = 4,
            border = "rounded",
            title = "{title}",
            title_pos = "center",
            { win = "list",  border = "none" },
            { win = "input", height = 1,     border = "top" },
        },
    }
end

-- Confirmations are centered on screen; palettes stay on the shared row.
M.select = column(0.3)
M.select.hidden = { "preview" }
M.select.layout.row = nil
M.commands = column(0.55)
M.list = M.commands

-- Centered modal with preview (for buffer list, file finder, etc.)
M.buffers = {
    layout = {
        box = "horizontal",
        width = 0.78,
        height = 0.78,
        {
            box = "vertical",
            width = 0.38,
            border = "rounded",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "list",  border = "none" },
            { win = "input", height = 1,     border = "top" },
        },
        { win = "preview", title = "{preview}", width = 0.62, border = "rounded" },
    },
}

-- File finder: similar to buffers but slightly wider list
M.files = {
    layout = {
        box = "horizontal",
        width = 0.78,
        height = 0.78,
        {
            box = "vertical",
            width = 0.40,
            border = "rounded",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "list",  border = "none" },
            { win = "input", height = 1,     border = "top" },
        },
        { win = "preview", title = "{preview}", width = 0.60, border = "rounded" },
    },
}

return M
