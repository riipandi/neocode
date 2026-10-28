-- ============================================================================
-- Cmdline <CR>: toast on command error
-- ============================================================================
-- Only `:` (ex) commands are intercepted: they run through vim.cmd() so errors
-- show up as a toast instead of the bottom-of-screen message.
--
-- Searches (/ and ?) are deliberately NOT intercepted: re-implementing them
-- with vim.fn.search() dropped search offsets (/pat/e, /pat/+2) and recursed
-- whenever a plugin used `:normal! /pat`. They now run natively; noice.nvim
-- routes the E486 message to the mini toast view (view_error = "mini").
vim.keymap.set("c", "<CR>", function()
    local cmdtype = vim.fn.getcmdtype()
    local cmdline = vim.fn.getcmdline()

    if cmdtype == ":" and cmdline ~= "" then
        -- Cancel native cmdline so our vim.cmd() takes over
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-c>", true, false, true),
            "n", false
        )

        -- Execute command and catch errors as toast
        local ok, err = pcall(vim.cmd, cmdline)
        if not ok then
            local msg = tostring(err)
            -- Strip VimL error prefix (e.g. "Vim:E492:")
            msg = msg:gsub(".-E%d+:", ""):gsub("[\r\n]", ""):gsub("^%s+", "")
            if msg == "" then
                msg = tostring(err):gsub("[\r\n]", "")
            end
            vim.notify(msg, vim.log.levels.ERROR, {
                title = "Cmdline",
                timeout = 3000,
            })
        end
        return
    end

    -- Default: feed Enter through for searches and non-: cmdline types
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<CR>", true, false, true),
        "n", false
    )
end, { desc = "Cmdline Enter with toast on command error" })
