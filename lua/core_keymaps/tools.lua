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

-- <C-S-s>: without a mapping it arrives as <C-s> (flow control) and does
-- nothing useful.
snacks.keymap.set("n", "<C-S-s>", function()
    Snacks.terminal(vim.o.shell, { lazy = false })
end, { desc = "Toggle terminal (Ctrl+Shift+S)" })

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

-- Opt+Shift+E: open or close the sidebar. Opt+Shift+E arrives as <M-E> in
-- terminals without the kitty keyboard protocol, <M-S-e> in those with it.
local function toggle_sidebar()
    local picker = Snacks.picker.get({ source = "explorer" })[1]
    if picker then picker:close() else Snacks.explorer() end
end
snacks.keymap.set("n", "<M-S-e>", toggle_sidebar, { desc = "File explorer: open/close sidebar" })
snacks.keymap.set("n", "<M-E>", toggle_sidebar, { desc = "File explorer: open/close sidebar" })

-- Opt+e: flip focus between the explorer and the editor. Opens the sidebar
-- when it is closed.
snacks.keymap.set("n", "<A-e>", function()
    local picker = Snacks.picker.get({ source = "explorer" })[1]
    if not picker then return Snacks.explorer() end
    if vim.bo.filetype:match("^snacks_picker") then
        if vim.api.nvim_win_is_valid(picker.main) then
            vim.api.nvim_set_current_win(picker.main)
        else
            vim.cmd("wincmd p")
        end
    else
        picker:focus("list")
    end
end, { desc = "File explorer: toggle focus (<A-e>)" })
