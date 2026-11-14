-- ============================================================================
-- Command Center
-- ============================================================================
-- A curated action list (title, description, key hint) plus the commands that
-- plugins and this config define. Recently used entries come first. Obscure
-- built-in ex commands stay out of the way: type `:` for those.
local snacks = require("snacks")
local dialog = require("dialog")

-- {category, title, description, what to run, keys that trigger it}
-- `run` is an ex command, or `keys` alone replays the mapping.
local ACTIONS = {
    { "File", "Save", "Write the current buffer", ":write", "<C-s>" },
    { "File", "Save as…", "Write to a new path", ":saveas" },
    { "File", "Find files", "Fuzzy file finder", nil, "<C-o>" },
    { "File", "Search text", "Live grep in the project", nil, "<leader>fw" },
    { "File", "Search word under cursor", "Live grep for the word", nil, "<leader>ff" },
    { "File", "Recent files", "Files opened before", ":lua Snacks.picker.recent()" },
    { "File", "Edit Neovim config", "Open ~/.config/nvim", nil, "<C-,>" },

    { "Buffer", "Buffers", "Switch between open buffers", nil, "<C-b>" },
    { "Buffer", "Pin buffer", "Keep it through close-others / close-all", ":TogglePin", "<C-S-.>" },
    { "Buffer", "Close buffer or split", "Close the active split, else the buffer", nil, "<C-x>" },
    { "Buffer", "Close other buffers", "Keeps pinned ones", nil, "<leader>bo" },
    { "Buffer", "Close all buffers", "Keeps pinned ones", nil, "<leader>bW" },
    { "Buffer", "Scratch buffer", "Toggle the scratch buffer", nil, "<leader>." },

    { "Edit", "Format file", "Format with conform / LSP", ":Format", "<C-f>" },
    { "Edit", "Toggle wrap", "Soft wrap long lines in this window", ":ToggleWrap", "<M-z>" },
    { "Edit", "Go to line", "Jump to line or line:col", nil, "<C-g>" },
    { "Edit", "Search and replace", "Project-wide replace (swpui)", nil, "<leader>sr" },
    { "Edit", "Document symbols", "Symbols of this buffer", ":lua Snacks.picker.lsp_symbols()", "<C-S-o>" },

    { "Window", "Split vertical", "Side-by-side split", ":vsplit", "<C-\\>" },
    { "Window", "Split horizontal", "Stacked split", ":split", "<C-S-\\>" },
    { "Window", "Close window", "Close the active window", ":close", "<leader>wq" },
    { "Window", "Equalize splits", "Make splits the same size", ":wincmd =", "<leader>w=" },
    { "Window", "Toggle explorer", "Open or close the sidebar", nil, "<M-S-e>" },
    { "Window", "Focus explorer / editor", "Switch focus", nil, "<M-e>" },
    { "Window", "Terminal", "Toggle the floating terminal", nil, "<leader>tt" },

    { "Git", "LazyGit", "Open LazyGit", nil, "<C-S-g>" },
    { "Git", "Git status", "Changed files", nil, "<leader>gs" },

    { "LSP", "Toggle inlay hints", "Type hints inline", nil, "<leader>li" },
    { "LSP", "Toggle diagnostics", "Show or hide diagnostics", nil, "<leader>ld" },
    { "LSP", "Toggle format on save", "Auto-format when writing", nil, "<leader>lf" },
    { "LSP", "Restart language servers", "Restart every attached client", ":LspRestart" },
    { "LSP", "Language server info", "Attached clients", ":LspInfo" },

    { "Debug", "Continue / start debugging", "Run or resume the session", ":DapContinue", "<leader>xx" },
    { "Debug", "Toggle breakpoint", "On the current line", ":DapToggleBreakpoint", "<leader>xb" },
    { "Debug", "Step over", "Next line, skipping calls", ":DapStepOver", "<leader>xo" },
    { "Debug", "Step into", "Enter the call", ":DapStepInto", "<leader>xi" },
    { "Debug", "Step out", "Run to the caller", ":DapStepOut", "<leader>xO" },
    { "Debug", "Stop debugging", "Terminate the session", ":DapTerminate", "<leader>xq" },
    { "Debug", "Debug console", "Toggle the REPL", ":DapToggleRepl" },

    { "AI", "Toggle AI completion", "Codestral on/off", ":MistralCodestralToggle", "<leader>it" },
    { "AI", "AI complete now", "Ask Codestral for a completion", ":MistralCodestralComplete", "<leader>ic" },
    { "AI", "Generate commit message", "From the staged diff", ":MistralCodestralCommitMsg", "<leader>ig" },
    { "AI", "AI authentication", "Manage the Mistral API key", ":MistralCodestralAuth", "<leader>iA" },
    { "AI", "AI health check", "Key, network and provider", ":MistralCodestralHealth", "<leader>ih" },

    { "Tools", "Mason", "Package manager UI", ":Mason" },
    { "Tools", "Mason packages", "Browse and install tools", ":MasonPkg", "<leader>tm" },
    { "Tools", "Update plugins", "vim.pack update", ":Update", "<leader>pu" },
    { "Tools", "Update parsers", "Update treesitter parsers", ":TSUpdate" },
    { "Tools", "Toggle transparent background", "Use the terminal background", ":TransparentToggle" },
    { "Tools", "Toggle secret masking", "Hide values in .env files", ":CloakToggle" },
    { "Tools", "Toggle markdown rendering", "Inline preview on/off", ":RenderMarkdown toggle", "<leader>mt" },
    { "Tools", "Open markdown link", "Link under the cursor", ":MarkdownOpenLink", "<leader>ml" },
    { "Tools", "Reload config", "Re-source config modules", ":ReloadConfig" },
    { "Tools", "Health check", "Version, tools, LSP, pack-lock", ":HealthCheck" },
    { "Tools", "Check health", "Neovim :checkhealth", ":checkhealth" },
    { "Tools", "Inspect key", "Show the notation of the next key", ":KeyProbe" },
    { "Tools", "Clear cache", "Delete the Neovim cache", ":CleanNvim" },
    { "Tools", "Clear session", "Forget this project's buffers and pins", ":SessionClear" },

    { "Help", "Help tags", "Search :help", ":lua Snacks.picker.help()" },
    { "Help", "Keymaps", "Search every key mapping", ":lua Snacks.picker.keymaps()" },
    { "Help", "Command history", "Recent : commands", ":lua Snacks.picker.command_history()" },
    { "Help", "Notifications", "Past toasts", ":lua Snacks.notifier.show_history()" },
    { "Help", "Messages", "Output of :messages", ":messages" },

    { "Session", "Quit all", "Leave Neovim", nil, "<C-q>" },
}

-- Plugin commands that only add noise to a palette.
local HIDE = {
    "^Netrw", "Explore$", "^N[rsw]", "^Ntree$", "^Plenary", "^NvimWebDevicons", "Match",
    "^Tutor$", "^Man$", "^Open$", "^UpdateRemotePlugins$", "^EditQuery$", "^Inspect",
    "^Todo", "^TS", "^BlinkCmp$", "^FormatCode$", "^Dap", "^FFF", "^Mistral", "^Gitsigns$",
    "^Lsp[IU]n", "^Cloak", "^Transparent", "^UrlView$", "^Crates$", "^WhichKey$", "^LazyDev$",
    "^RenderMarkdown$", "^MarkdownOpenLink$",
}

local PREFIX_CATEGORY = {
    { "^Mason", "Tools" }, { "^Mistral", "AI" }, { "^Dap", "Debug" }, { "^Cloak", "Tools" },
    { "^Gitsigns", "Git" }, { "^Lsp", "LSP" }, { "^FFF", "File" }, { "^Todo", "Tools" },
    { "^Transparent", "View" }, { "^TS", "Tools" }, { "^Crates", "Tools" }, { "^Markdown", "Tools" },
    { "^RenderMarkdown", "Tools" }, { "^UrlView", "Tools" },
}

local function category_of(name)
    for _, rule in ipairs(PREFIX_CATEGORY) do
        if name:match(rule[1]) then return rule[2] end
    end
    return "Command"
end

local function hidden(name)
    for _, p in ipairs(HIDE) do
        if name:match(p) then return true end
    end
    return false
end

-- Recently used entries -----------------------------------------------------
local recent_file = vim.fn.stdpath("state") .. "/command_center.json"
local MAX_RECENT = 8

local function load_recent()
    local f = io.open(recent_file, "r")
    if not f then return {} end
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    return ok and type(data) == "table" and data or {}
end

local function remember(id)
    local list = vim.tbl_filter(function(x) return x ~= id end, load_recent())
    table.insert(list, 1, id)
    for i = #list, MAX_RECENT + 1, -1 do list[i] = nil end
    vim.fn.mkdir(vim.fn.fnamemodify(recent_file, ":h"), "p")
    local f = io.open(recent_file, "w")
    if f then
        f:write(vim.json.encode(list))
        f:close()
    end
end

-- Items ----------------------------------------------------------------------
local function key_hint(keys)
    if not keys then return nil end
    if vim.fn.maparg(keys, "n") == "" then return nil end
    return (keys:gsub("<leader>", "␣"):gsub("<[Ss]pace>", "␣"))
end

local function exists(cmd)
    local name = cmd:match("^:(%w+)")
    if not name then return true end
    return name == "lua" or vim.fn.exists(":" .. name) >= 1
end

local function build_items()
    local items, seen = {}, {}
    for _, a in ipairs(ACTIONS) do
        local category, title, desc, run, keys = a[1], a[2], a[3], a[4], a[5]
        local hint = key_hint(keys)
        local available = (run and exists(run)) or (not run and hint ~= nil)
        if available then
            if run then seen[run:match("^:(%w+)") or run] = true end
            items[#items + 1] = {
                id = title, category = category, title = title, desc = desc or "",
                run = run, keys = keys, hint = hint,
            }
        end
    end

    for name, def in pairs(vim.api.nvim_get_commands({})) do
        if not seen[name] and not hidden(name) then
            local desc = type(def.definition) == "string" and def.definition or ""
            if desc:find("^<Lua") or desc:find("^:lua") or #desc > 80 then desc = "" end
            items[#items + 1] = {
                id = ":" .. name, category = category_of(name), title = name, desc = desc,
                run = ":" .. name, command = true,
            }
        end
    end

    -- recent first, then the curated list as written, then the rest A-Z
    local rank = {}
    for i, id in ipairs(load_recent()) do rank[id] = i end
    for i, item in ipairs(items) do item.order = i end
    table.sort(items, function(a, b)
        local ra, rb = rank[a.id], rank[b.id]
        if ra or rb then
            if ra and rb then return ra < rb end
            return ra ~= nil
        end
        if a.command ~= b.command then return not a.command end
        if a.command then
            if a.category ~= b.category then return a.category < b.category end
            return a.title < b.title
        end
        return a.order < b.order
    end)

    for i, item in ipairs(items) do
        item.recent = rank[item.id] ~= nil
        item.idx = i
        item.text = table.concat({ item.title, item.category, item.desc }, " ")
    end
    return items
end

-- Run -------------------------------------------------------------------------
-- Run the command right away. Only a command that needs an argument opens the
-- cmdline, prefilled, so the argument can be typed.
local function run_command(name)
    local user_cmd = vim.api.nvim_get_commands({})[name]
    if not (user_cmd and (user_cmd.nargs == "1" or user_cmd.nargs == "+")) then
        local ok, err = pcall(vim.cmd, name)
        if ok then return end
        -- E471: Argument required (built-in commands do not report nargs)
        if not tostring(err):find("E471", 1, true) then
            vim.notify(tostring(err):match("E%d+:.*") or tostring(err), vim.log.levels.ERROR, { title = "Command" })
            return
        end
    end
    vim.fn.feedkeys(":" .. name .. " ", "n")
end

local function execute(item)
    remember(item.id)
    if item.run then
        return run_command(item.run:sub(2))
    end
    vim.api.nvim_feedkeys(vim.keycode(item.keys), "m", false)
end

-- UI --------------------------------------------------------------------------
local TITLE_W = 28
local CATEGORY_W = 8

local function format(item)
    local ret = {
        { item.recent and "↺ " or "  ", "Special" },
        { snacks.picker.util.align(item.category, CATEGORY_W), "Comment" },
        { " " },
        { snacks.picker.util.align(item.title, TITLE_W), "Function" },
    }
    if item.hint then
        ret[#ret + 1] = { " " .. item.hint, "NonText" }
    end
    return ret
end

local function show()
    Snacks.picker({
        title = "Commands Center",
        layout = { preset = "list", preview = false },
        win = { input = { keys = dialog.keys }, list = { keys = dialog.keys } },
        items = build_items(),
        format = format,
        confirm = function(picker, item)
            if not item then return end
            picker:close()
            return picker:norm(function() execute(item) end)
        end,
    })
end

snacks.keymap.set("n", "<leader>:", show, { desc = "Command palette" })
snacks.keymap.set("n", "<C-p>", show, { desc = "Command palette" })
