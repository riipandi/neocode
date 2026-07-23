-- ============================================================================
-- User Commands
-- ============================================================================
-- Custom user commands for common operations.
-- ============================================================================
local M = {}

-- :Format - Format the current buffer with the conform plugin
vim.api.nvim_create_user_command("Format", function(args)
    if args.count > 0 then
        -- :3Format → format range from line 1 to current
        vim.cmd(string.format("silent! normal! %dG=g", args.count))
    else
        -- :Format → format the whole buffer
        vim.cmd("silent! normal! gg=G")
    end
end, { desc = "Format current buffer (use :N Format for range)" })

-- :Update - Update all plugins via vim.pack
vim.api.nvim_create_user_command("Update", function()
    vim.pack.update()
end, { desc = "Update all plugins" })

-- :LspRestart - Restart LSP clients (for all attached clients)
vim.api.nvim_create_user_command("LspRestart", function()
    local clients = vim.lsp.get_clients()
    for _, client in ipairs(clients) do
        client.stop()
    end
    vim.cmd("doautocmd User LSPAttach") -- trigger LspAttach to re-attach
    -- Alternative: vim.cmd("edit") to reload current buffer
    Snacks.notify.info("Restarted " .. #clients .. " LSP clients")
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
