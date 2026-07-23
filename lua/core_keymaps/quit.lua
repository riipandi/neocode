-- ============================================================================
-- Quit: <C-q>, <A-q>, <leader>q, <leader>qq
-- ============================================================================
-- With smart confirmation dialog that handles unsaved buffers and
-- properly returns cursor if the user cancels.
local snacks = require("snacks")
local M = {}

local function confirm_quit()
    -- If cursor is in the file explorer, switch to main editor first
    local buf_name = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype
    local was_in_explorer = buf_name:match("snacks_explorer") or filetype == "snacks_picker_list"
    local prev_win = was_in_explorer and vim.api.nvim_get_current_win() or nil
    if was_in_explorer then
        vim.cmd("wincmd p")
    end

    -- Helper to restore cursor position if quitting is cancelled
    local function restore()
        if prev_win and vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
        end
    end

    -- Check if any buffer has unsaved changes
    local has_unsaved = false
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].modified then
            has_unsaved = true
            break
        end
    end

    if has_unsaved then
        vim.ui.select({ 'Save & Quit', 'Quit without saving', 'Cancel' }, {
            prompt = 'You have unsaved buffers:',
        }, function(choice)
            if choice == 'Save & Quit' then
                vim.cmd('wa')
                vim.cmd('qa')
            elseif choice == 'Quit without saving' then
                vim.cmd('qa!')
            else
                restore()
            end
        end)
    else
        -- No unsaved changes: simple Yes/No
        vim.ui.select({ 'Yes', 'No' }, {
            prompt = 'Quit Neovim?',
        }, function(choice)
            if choice == 'Yes' then
                vim.cmd('qa')
            else
                restore()
            end
        end)
    end
end

snacks.keymap.set("n", "<C-q>", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<A-q>", confirm_quit, { desc = 'Quit all (Option+q)' })
snacks.keymap.set("n", "<leader>q", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<leader>qq", confirm_quit, { desc = 'Quit all' })

M.confirm_quit = confirm_quit
return M
