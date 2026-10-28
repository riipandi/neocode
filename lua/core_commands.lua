-- ============================================================================
-- User Commands
-- ============================================================================
-- Custom user commands for common operations.
-- ============================================================================
local M = {}

-- :Format - Format the current buffer with conform.nvim
-- :3Format / :%Format - same, kept for muscle memory (range is ignored, the
-- whole buffer is formatted).
vim.api.nvim_create_user_command("Format", function()
    local ok, err = pcall(require("conform").format, {
        async = false,
        timeout_ms = 2000,
        lsp_format = "fallback",
    })
    if not ok then
        vim.notify("Format failed: " .. tostring(err), vim.log.levels.ERROR, { title = "Format" })
    end
end, { desc = "Format current buffer (conform.nvim)", range = true })

-- :Update - Update all plugins via vim.pack
vim.api.nvim_create_user_command("Update", function()
    vim.pack.update()
end, { desc = "Update all plugins" })

-- :LspRestart - Restart LSP clients (for all attached clients)
vim.api.nvim_create_user_command("LspRestart", function()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
        vim.notify("No LSP clients running", vim.log.levels.WARN, { title = "LSP" })
        return
    end

    local names = {}
    for _, client in ipairs(clients) do
        names[client.name] = true
        client:stop(true)
    end

    -- vim.lsp.enable() re-triggers the attach logic for buffers whose
    -- filetype matches, which is the supported way to restart a client.
    vim.defer_fn(function()
        for name in pairs(names) do
            pcall(vim.lsp.enable, name)
        end
    end, 100)

    vim.notify("Restarting " .. #clients .. " LSP client(s)", vim.log.levels.INFO, { title = "LSP" })
end, { desc = "Restart all LSP clients" })

-- :HealthCheck - Run a comprehensive health check
vim.api.nvim_create_user_command("HealthCheck", function()
    local issues = {}

    -- Check Neovim version
    local nvim_version = vim.version()
    if nvim_version.major < 0 or (nvim_version.major == 0 and nvim_version.minor < 11) then
        table.insert(issues, "Neovim 0.12+ recommended (you have " .. tostring(vim.version()) .. ")")
    end

    -- Check required tools
    local tools = {
        { name = "ripgrep", cmd = "rg",      usage = "live grep, fff.nvim" },
        { name = "fd",      cmd = "fd",      usage = "fff.nvim (optional)" },
        { name = "lazygit", cmd = "lazygit", usage = "<leader>gg" },
    }
    for _, tool in ipairs(tools) do
        if vim.fn.executable(tool.cmd) == 0 then
            table.insert(issues, string.format("Missing: %s (%s)", tool.name, tool.usage))
        end
    end

    -- Check LSP clients on current buffer
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 and vim.bo.filetype ~= "" then
        table.insert(issues, "No LSP attached for filetype: " .. vim.bo.filetype)
    end

    -- Check nvim-pack-lock
    if vim.fn.filereadable(vim.fn.stdpath("config") .. "/nvim-pack-lock.json") == 0 then
        table.insert(issues, "nvim-pack-lock.json missing — plugins may not be tracked")
    end

    if #issues == 0 then
        Snacks.notify.info("Health check passed! No issues found.")
    else
        local msg = "Issues found:\n  - " .. table.concat(issues, "\n  - ")
        vim.notify(msg, vim.log.levels.WARN, { title = "Health Check", timeout = 8000 })
    end
end, { desc = "Run health check" })

-- :ReloadConfig - Reload Neovim config without restarting
vim.api.nvim_create_user_command("ReloadConfig", function()
    -- Reload init.lua and all core modules
    for name, _ in pairs(package.loaded) do
        if name:match("^core_") or name == "init" then
            package.loaded[name] = nil
        end
    end
    vim.cmd("source " .. vim.fn.stdpath("config") .. "/init.lua")
    Snacks.notify.info("Config reloaded")
end, { desc = "Reload Neovim config" })

return M
