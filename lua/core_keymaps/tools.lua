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

-- ============================================================================
-- Open the repository page in the default browser (gR)
-- ============================================================================
-- Shadows the builtin `gR` (virtual replace mode), which is rarely typed.

--- Browser URL for a git remote URL: scp-like (git@host:owner/repo.git),
--- ssh://, git://, http(s)://. Credentials, port and ".git" are dropped.
---@param remote string
---@return string?
local function remote_to_url(remote)
    remote = vim.trim(remote)
    local host, path = remote:match("^[%w._-]+@([^:/]+):(.+)$") -- scp-like
    if not host then
        local rest = remote:match("^%a[%w+.-]*://(.+)$")
        if not rest then
            return nil
        end
        host, path = rest:gsub("^[^/]*@", ""):match("^([^/]+)/(.+)$")
        if host then
            host = host:gsub(":%d+$", "")
        end
    end
    if not host or not path then
        return nil
    end
    path = path:gsub("^/+", ""):gsub("/+$", ""):gsub("%.git$", "")
    return ("https://%s/%s"):format(host, path)
end

snacks.keymap.set("n", "gR", function()
    local dir = vim.fn.expand("%:p:h")
    dir = vim.fn.isdirectory(dir) == 1 and dir or vim.fn.getcwd()
    local res = vim.system({ "git", "-C", dir, "config", "--get", "remote.origin.url" }, { text = true }):wait()
    local remote = res.code == 0 and vim.trim(res.stdout) or ""
    if remote == "" then
        return vim.notify("No git remote 'origin' here", vim.log.levels.WARN, { title = "Git" })
    end
    local url = remote_to_url(remote)
    if not url then
        return vim.notify("Cannot turn the remote into a URL: " .. remote, vim.log.levels.WARN, { title = "Git" })
    end
    local ok, err = pcall(vim.ui.open, url)
    if not ok then
        return vim.notify(tostring(err), vim.log.levels.ERROR, { title = "Git" })
    end
    vim.notify(url, vim.log.levels.INFO, { title = "Git" })
end, { desc = "Open the git repository in the browser" })

return { remote_to_url = remote_to_url }
