-- ============================================================================
-- Cmdline <CR>: toast on search failure or command error
-- ============================================================================
-- Intercept <CR> in cmdline mode:
-- For / and ? searches: prevent native E486 `Pattern not found` and show
--   a toast instead.
-- For : commands: execute via vim.cmd() and show command errors as toast,
--   avoiding the native bottom-of-terminal message.
vim.keymap.set("c", "<CR>", function()
    local cmdtype = vim.fn.getcmdtype()
    local cmdline = vim.fn.getcmdline()

    if (cmdtype == "/" or cmdtype == "?") and cmdline ~= "" then
        -- Add to search history so <Up> works for next search
        vim.fn.histadd("search", cmdline)
        vim.fn.setreg("/", cmdline)

        -- Cancel cmdline (prevent native search from executing)
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<C-c>", true, false, true),
            "n", false
        )

        -- Execute search ourselves
        local dir = cmdtype == "?" and "b" or ""
        local ok, found = pcall(vim.fn.search, cmdline, "w" .. dir)

        if not ok then
            vim.notify("Search error: " .. tostring(found), vim.log.levels.ERROR, {
                title = "Search",
                timeout = 3000,
            })
        elseif found == 0 then
            vim.notify("Pattern not found: " .. cmdline, vim.log.levels.WARN, {
                title = "Search",
                timeout = 2500,
            })
        end
        return
    end

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

    -- Default: feed Enter through for non-search, non-: commands (e.g. =, @)
    vim.api.nvim_feedkeys(
        vim.api.nvim_replace_termcodes("<CR>", true, false, true),
        "n", false
    )
end, { desc = "Cmdline Enter with toast on error" })

return M
