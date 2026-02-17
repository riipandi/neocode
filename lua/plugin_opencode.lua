-- ============================================================================
-- OpenCode: AI Code Assistant (ChatGPT, Claude, etc.)
-- ============================================================================

-- Requires snacks.nvim (loaded in core_plugins.lua)

vim.pack.add {
    { src = "https://github.com/nickjvandyke/opencode.nvim" },
}

local snacks = require "snacks"

-- ============================================================================
-- OpenCode Configuration
-- ============================================================================

vim.g.opencode_opts = {
    auto_reload = true,
    auto_focus = false,
    command = "opencode",
    provider = {
        enabled = "snacks",
        snacks = {
            win = {
                position = "right",
                width = math.floor(vim.o.columns * 0.35),
            },
        },
    },
}

-- ============================================================================
-- Toggle & Focus
-- ============================================================================

snacks.keymap.set("n", "<C-S-l>", function()
    require("opencode").toggle()
end, { desc = "OpenCode: Toggle panel" })
snacks.keymap.set("n", "<leader>oo", function()
    require("opencode").toggle()
end, { desc = "OpenCode: Toggle panel" })

snacks.keymap.set("n", "<leader>of", function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        local name = vim.api.nvim_buf_get_name(buf)
        if ft == "opencode_terminal" or name:match "opencode" then
            vim.api.nvim_set_current_win(win)
            return
        end
    end
    require("opencode").toggle()
end, { desc = "OpenCode: Focus panel" })

-- Auto-escape keymaps for OpenCode terminal
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "opencode_terminal",
    callback = function()
        snacks.keymap.set("n", "<Esc>", function()
            vim.cmd "wincmd p"
        end, { buffer = 0, desc = "Return to editor" })
        snacks.keymap.set(
            "t",
            "<Esc>",
            [[<C-\><C-n>]],
            { buffer = 0, desc = "Exit terminal mode" }
        )
    end,
    once = false,
})

-- ============================================================================
-- Ask & Select
-- ============================================================================

snacks.keymap.set({ "n", "x" }, "<leader>oa", function()
    require("opencode").ask("@this: ", { submit = true })
end, { desc = "OpenCode: Ask about this" })
snacks.keymap.set({ "n", "x" }, "<leader>os", function()
    require("opencode").select()
end, { desc = "OpenCode: Select prompt/command" })
snacks.keymap.set("n", "<leader>oc", function()
    require("opencode").command()
end, { desc = "OpenCode: Command" })

-- ============================================================================
-- Session Management
-- ============================================================================

snacks.keymap.set("n", "<leader>on", function()
    require("opencode").command "session.new"
end, { desc = "OpenCode: New session" })
snacks.keymap.set("n", "<leader>oi", function()
    require("opencode").command "session.interrupt"
end, { desc = "OpenCode: Interrupt session" })
snacks.keymap.set("n", "<leader>oA", function()
    require("opencode").command "agent.cycle"
end, { desc = "OpenCode: Cycle agent" })

snacks.keymap.set("n", "<leader>ox", function()
    _G.ui_select("Exit OpenCode?", { "Yes", "No" }, function(choice)
        if choice == "Yes" then
            local notify_orig = vim.notify
            vim.notify = function() end

            pcall(function()
                require("opencode").stop()
            end)

            vim.schedule(function()
                vim.notify = notify_orig
            end)
        end
    end)
end, { desc = "OpenCode: Exit" })

-- ============================================================================
-- Operator Keymaps (add range/line to prompt)
-- ============================================================================

snacks.keymap.set({ "n", "x" }, "go", function()
    return require("opencode").operator "@this "
end, { desc = "OpenCode: Add range to prompt", expr = true })
snacks.keymap.set("n", "goo", function()
    return require("opencode").operator "@this " .. "_"
end, { desc = "OpenCode: Add line to prompt", expr = true })

-- ============================================================================
-- Scroll OpenCode Panel
-- ============================================================================

snacks.keymap.set("n", "<S-C-u>", function()
    require("opencode").command "session.half.page.up"
end, { desc = "OpenCode: Scroll up" })
snacks.keymap.set("n", "<S-C-d>", function()
    require("opencode").command "session.half.page.down"
end, { desc = "OpenCode: Scroll down" })
