-- ============================================================================
-- Buffer Management: <C-x>, <leader>bd/bb/bo, <C-S-w>
-- ============================================================================
-- Smart <C-x>:
--   • multiple listed buffers → close current, load previous (or most recent) one
--   • only listed buffer remaining → close current, create empty buffer
--   • explorer is preserved (it lives in a separate window)
local snacks = require("snacks")
local function smart_close()
    -- Don't close the explorer/picker window via <C-x>
    if (vim.bo.filetype or ""):match("snacks_picker") then
        return
    end

    -- Save prompt for unsaved changes
    local function do_close(force)
        -- Snacks.bufdelete replaces the current buffer with the most-recent
        -- listed buffer (or creates an empty one if none remain). Explorer
        -- is preserved because it lives in a separate window.
        Snacks.bufdelete({ buf = 0, force = force })
    end

    if vim.bo.modified then
        vim.ui.select({ 'Save & Close', 'Close without saving', 'Cancel' }, {
            prompt = 'Buffer has unsaved changes:',
            focus = 'list',
        }, function(choice)
            if choice == 'Save & Close' then
                local ok, err = pcall(vim.cmd, 'w')
                if not ok then
                    vim.notify('Save failed: ' .. tostring(err), vim.log.levels.ERROR, { title = 'Buffer' })
                    return
                end
                do_close(false)
            elseif choice == 'Close without saving' then
                do_close(true)
            end
        end)
    else
        do_close(false)
    end
end

snacks.keymap.set("n", "<C-x>", smart_close, { desc = 'Close buffer (smart)' })

-- Save: <C-s> writes the current buffer from normal and insert mode without
-- leaving insert mode. Special buffers are reported instead of erroring, and
-- an unnamed buffer asks for a path first.
local function save_file()
    local buftype = vim.bo.buftype
    -- acwrite buffers have a BufWriteCmd and can legitimately be written
    if buftype ~= "" and buftype ~= "acwrite" then
        vim.notify("Nothing to write (" .. buftype .. " buffer)", vim.log.levels.WARN, { title = "Write" })
        return
    end

    -- Write and report: a real write notifies "Saved", an unchanged buffer
    -- stays quiet, a failed write shows the error the command raised.
    local function write(cmd, prior_name)
        local was_modified = vim.bo.modified
        local ok, err = pcall(vim.cmd, cmd)
        if not ok then
            vim.notify("Write failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Write" })
            return
        end
        if not was_modified then return end
        local name = vim.api.nvim_buf_get_name(0)
        local label = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or (prior_name or "buffer")
        vim.notify("Saved " .. label, vim.log.levels.INFO, { title = "Write", timeout = 1200 })
    end

    if vim.api.nvim_buf_get_name(0) == "" then
        local cwd = vim.uv.cwd() or vim.fn.getcwd()
        vim.ui.input({ prompt = "Save as: ", default = cwd .. "/", completion = "file" }, function(input)
            if not input or input == "" then return end
            write("write " .. vim.fn.fnameescape(input), vim.fn.fnamemodify(input, ":~:."))
        end)
        return
    end
    write("silent write")
end

vim.keymap.set({ "n", "i" }, "<C-s>", save_file, { desc = "Save file" })

-- Close all buffers with snacks
snacks.keymap.set("n", "<leader>bW", function()
    Snacks.bufdelete.all()
end, { desc = "Close all buffers" })

-- Unmapped <C-S-w> falls back to <C-w>, the window prefix, so a mistyped
-- Ctrl+Shift+W would start a window command. Swallow it instead of binding
-- something destructive; <leader>bW closes all buffers.
vim.keymap.set("n", "<C-S-w>", "<Nop>", { desc = "Swallowed (would fall back to <C-w>)" })

-- Delete buffer
snacks.keymap.set("n", "<leader>bd", function()
    Snacks.bufdelete()
end, { desc = "Delete buffer" })

-- Buffer picker
snacks.keymap.set("n", "<leader>bb", function()
    Snacks.picker.buffers({
        layout = { preset = "buffers" },
    })
end, { desc = "Buffer picker" })

-- Close other buffers (keep only current)
snacks.keymap.set("n", "<leader>bo", function()
    Snacks.bufdelete.other()
end, { desc = "Close other buffers" })
