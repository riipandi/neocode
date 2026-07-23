-- ============================================================================
-- Snacks Picker Layouts
-- ============================================================================
-- Custom layout definitions for the snacks.picker.
-- These are referenced by name in snacks.setup via picker.layouts.<name>.
-- ============================================================================
local M = {}

-- Small popup at top of screen for quick selections (e.g. : commands)
M.select = {
    hidden = { "preview" },
    layout = {
        backdrop = false,
        width = 0.2,
        min_width = 20,
        height = 0.3,
        min_height = 4,
        box = "vertical",
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "list",  border = "none" },
        { win = "input", height = 1,     border = "top" },
    },
}

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

-- : commands picker
M.commands = {
    layout = {
        box = "vertical",
        width = 0.40,
        height = 0.55,
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "list",  border = "none" },
        { win = "input", height = 1,     border = "top" },
    },
}

-- : command history picker
M.cmd_history = {
    layout = {
        box = "vertical",
        width = 0.40,
        height = 0.55,
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "list",  border = "none" },
        { win = "input", height = 1,     border = "top" },
    },
}

return M
