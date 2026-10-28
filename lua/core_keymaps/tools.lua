-- ============================================================================
-- Tools: Terminal, Resource Monitor, File Explorer open/close
-- ============================================================================
local snacks = require("snacks")

-- Terminal
snacks.keymap.set("n", "<leader>tt", function()
    Snacks.terminal(vim.o.shell, {
        lazy = false,
    })
end, { desc = "Toggle terminal" })

-- Resource Monitor (mactop on Mac, btop on Linux)
-- Install: brew install mactop (Mac) or brew install btop (cross-platform)
snacks.keymap.set("n", "<leader>tr", function()
    local monitor
    for _, candidate in ipairs({ "mactop", "btop", "htop" }) do
        if vim.fn.executable(candidate) == 1 then
            monitor = candidate
            break
        end
    end
    if not monitor then
        vim.notify("No resource monitor found. Install mactop (macOS) or btop.", vim.log.levels.WARN,
            { title = "Tools" })
        return
    end
    Snacks.terminal(monitor, {
        lazy = false,
        title = "Resource Monitor",
    })
end, { desc = "Resource monitor" })

-- File Explorer (toggle)
snacks.keymap.set("n", "<leader>e", function()
    Snacks.explorer()
end, { desc = "Toggle file explorer" })

-- File Explorer (close if in explorer, else focus or open)
snacks.keymap.set("n", "<A-e>", function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype
    local in_explorer = buf_name:match("snacks_explorer") or filetype == "snacks_picker_list"

    if in_explorer then
        local pickers = Snacks.picker.get({ source = "explorer" })
        if pickers and #pickers > 0 then
            pickers[1]:close()
        end
        return
    end

    -- Focus explorer if open, otherwise open it
    local pickers = Snacks.picker.get({ source = "explorer" })
    if pickers and #pickers > 0 then
        pickers[1]:focus()
    else
        Snacks.explorer()
    end
end, { desc = "File explorer: close/focus (<A-e>)" })
