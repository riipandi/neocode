-- ============================================================================
-- Pinned buffers: <C-S-.>, <leader>bp, :TogglePin
-- ============================================================================
-- A pinned buffer survives "close other buffers" and "close all buffers",
-- asks before it is closed explicitly, and is marked in the buffer picker and
-- the statusline. Pins last for the session.
local M = {}

local ICON = "󰐃"

function M.is_pinned(buf)
    return vim.b[buf or 0].pinned == true
end

function M.toggle()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].buftype ~= "" then
        vim.notify("Only file buffers can be pinned", vim.log.levels.WARN, { title = "Pin" })
        return
    end
    vim.b[buf].pinned = not M.is_pinned(buf) or nil
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    vim.notify((M.is_pinned(buf) and "Pinned " or "Unpinned ") .. (name ~= "" and name or "[No Name]"),
        vim.log.levels.INFO, { title = "Pin" })
    require("lualine").refresh()
end

-- Run `close` right away, or after confirming when the buffer is pinned.
function M.confirm_close(buf, close)
    if not M.is_pinned(buf) then
        return close()
    end
    vim.ui.select({ "Close pinned buffer", "Cancel" }, {
        prompt = "Buffer is pinned:",
        focus = "list",
    }, function(choice)
        if choice == "Close pinned buffer" then
            close()
        end
    end)
end

function M.close_others()
    local current = vim.api.nvim_get_current_buf()
    Snacks.bufdelete({ filter = function(b) return b ~= current and not M.is_pinned(b) end })
end

function M.close_all()
    Snacks.bufdelete({ filter = function(b) return not M.is_pinned(b) end })
end

function M.buffers()
    Snacks.picker.buffers({
        layout = { preset = "buffers" },
        transform = function(item)
            if item.buf and M.is_pinned(item.buf) then
                item.flags = item.flags .. ICON
            end
        end,
    })
end

function M.statusline()
    return M.is_pinned(0) and ICON or ""
end

vim.api.nvim_create_user_command("TogglePin", M.toggle, { desc = "Pin or unpin the current buffer" })

-- Ctrl+Shift+. needs the kitty keyboard protocol; terminals spell it <C-S-.> or <C->>.
for _, lhs in ipairs({ "<C-S-.>", "<C->>", "<leader>bp" }) do
    vim.keymap.set("n", lhs, M.toggle, { desc = "Pin buffer" })
end

return M
