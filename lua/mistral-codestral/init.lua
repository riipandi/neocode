-- lua/mistral-codestral/init.lua
-- Main entry point for the Mistral Codestral AI completion plugin (forked).
-- Optimized for Neovim 0.11+/0.12+ and blink.cmp v1.6+.

local M = {}

M.VERSION = "1.1.0-fork"

-- Default configuration
local default_config = {
    -- API key. Leave nil to use the env var below.
    api_key = nil,
    model = "codestral-latest",
    max_tokens = 256,
    temperature = 0.1,
    stop_tokens = { "\n\n" },
    timeout = 10000, -- HTTP timeout in milliseconds
    enabled = true, -- Global enable/disable
    debug = false, -- Debug logging

    -- blink.cmp integration
    max_items = 5,       -- Max completion items to show
    min_keyword_length = 0, -- Minimum characters before triggering
    async = false,       -- Sync vs async completion
    timeout_ms = 2000,   -- blink.cmp timeout

    -- Virtual text (ghost-text) preview
    virtual_text = {
        enabled = true,
        manual = false,
        idle_delay = 800,
        min_chars = 3, -- Trigger only after N chars in current word
        priority = 65535,
        filetypes = {}, -- empty = use default_filetype_enabled
        default_filetype_enabled = true,
        key_bindings = {
            accept = "<M-l>",
            accept_word = "<C-Right>",
            accept_line = "<C-Down>",
            next = "<M-]>",
            prev = "<M-[>",
            clear = "<C-c>",
        },
    },

    -- Buffer and filetype exclusions
    exclusions = {
        filetypes = {
            "help",
            "qf",
            "neo-tree",
            "neo-tree-popup",
            "alpha",
            "dashboard",
            "nvim-tree",
            "trouble",
            "lspinfo",
            "mason",
            "lazy",
            "TelescopePrompt",
            "TelescopeResults",
            "snacks_picker_list",
        },
        buffer_patterns = {
            "^term://",
            "^%[Command Line%]",
            "^neo%-tree",
            "^NvimTree",
            "^%[Scratch%]",
            "^snacks%-",
        },
        buftypes = {
            "help",
            "quickfix",
            "terminal",
            "prompt",
            "nofile",
        },
    },

    -- Authentication
    auth = {
        methods = { "environment", "keyring", "config", "prompt" },
        validate_on_startup = false, -- Off by default to avoid network on startup
        cache_validation = true,
    },

    -- LSP workspace root detection
    workspace_root = {
        use_lsp = true,
        find_root = nil,
        paths = {
            ".git",
            ".svn",
            ".hg",
            "package.json",
            "Cargo.toml",
            "pyproject.toml",
            "go.mod",
            "requirements.txt",
        },
    },
}

local config = {}
local uv = vim.uv or vim.loop -- Neovim 0.10+ exposes vim.uv

-- Constants for context extraction
local CONTEXT_MAX_LINES = 100
local CONTEXT_MIN_LINES = 20
local CONTEXT_SIZE_RATIO = 4

-- Constants for floating window detection
local MIN_POPUP_WIDTH = 20
local MIN_POPUP_HEIGHT = 3

-- Debug logger
local function debug_log(message, level)
    if config.debug then
        level = level or vim.log.levels.DEBUG
        vim.notify("[mistral-codestral] " .. message, level)
    end
end

-- Validate exclusion patterns
local function validate_exclusion_patterns()
    if not config.exclusions then
        return true
    end

    local valid = true

    if config.exclusions.buffer_patterns then
        for i, pattern in ipairs(config.exclusions.buffer_patterns) do
            local ok = pcall(string.match, "test", pattern)
            if not ok then
                debug_log(
                    "Invalid regex pattern in buffer_patterns[" .. i .. "]: " .. pattern,
                    vim.log.levels.WARN
                )
                valid = false
            end
        end
    end

    debug_log("Exclusion configuration loaded:")
    debug_log("  - Filetypes: " .. #(config.exclusions.filetypes or {}) .. " entries")
    debug_log("  - Buffer patterns: " .. #(config.exclusions.buffer_patterns or {}) .. " entries")
    debug_log("  - Buffer types: " .. #(config.exclusions.buftypes or {}) .. " entries")

    return valid
end

-- Find workspace root using LSP first, then filesystem
local function find_workspace_root()
    if not config.workspace_root then
        return vim.fn.getcwd()
    end

    if config.workspace_root.find_root then
        local ok, root = pcall(config.workspace_root.find_root)
        if ok and root then
            return root
        end
    end

    if config.workspace_root.use_lsp then
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if clients and #clients > 0 then
            local folders = clients[1].config.workspace_folders
            if folders and #folders > 0 then
                return folders[1].name
            end
            if clients[1].config.root_dir then
                return clients[1].config.root_dir
            end
        end
    end

    -- Fallback: walk up looking for workspace markers
    local current_dir = vim.fn.expand("%:p:h")
    if current_dir == "" then
        return vim.fn.getcwd()
    end
    local function find_root(path)
        for _, indicator in ipairs(config.workspace_root.paths or {}) do
            if vim.uv.fs_stat(path .. "/" .. indicator) then
                return path
            end
        end
        local parent = vim.fn.fnamemodify(path, ":h")
        if parent == path or parent == "" then
            return nil
        end
        return find_root(parent)
    end

    return find_root(current_dir) or current_dir or vim.fn.getcwd()
end

-- Get buffer language from LSP or filetype
local function get_buffer_language()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if clients and #clients > 0 and clients[1].config.filetypes then
        return clients[1].config.filetypes[1]
    end
    return vim.bo.filetype
end

-- Per-buffer exclusion cache
local exclusion_cache = {}
local cache_invalidation_autocmd = nil

local function clear_exclusion_cache(bufnr)
    if bufnr then
        exclusion_cache[bufnr] = nil
    else
        exclusion_cache = {}
    end
end

local function setup_cache_invalidation()
    if cache_invalidation_autocmd then
        return
    end

    cache_invalidation_autocmd = vim.api.nvim_create_augroup("MistralCodestralExclusionCache", { clear = true })

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "BufWritePost", "FileType" }, {
        group = cache_invalidation_autocmd,
        callback = function(ev)
            clear_exclusion_cache(ev.buf)
        end,
    })

    vim.api.nvim_create_autocmd("BufDelete", {
        group = cache_invalidation_autocmd,
        callback = function(ev)
            clear_exclusion_cache(ev.buf)
        end,
    })
end

local function is_filetype_excluded(filetype)
    if not config.exclusions or not config.exclusions.filetypes then
        return false
    end
    for _, excluded_ft in ipairs(config.exclusions.filetypes) do
        if filetype == excluded_ft then
            return true
        end
    end
    return false
end

local function is_buftype_excluded(buftype)
    if not config.exclusions or not config.exclusions.buftypes then
        return false
    end
    for _, excluded_bt in ipairs(config.exclusions.buftypes) do
        if buftype == excluded_bt then
            return true
        end
    end
    return false
end

local function is_buffer_name_excluded(bufname)
    if not config.exclusions or not config.exclusions.buffer_patterns or not bufname or bufname == "" then
        return false
    end

    local relative_name = vim.fn.fnamemodify(bufname, ":t")
    for _, pattern in ipairs(config.exclusions.buffer_patterns) do
        local match_found = false
        pcall(function()
            if string.match(relative_name, pattern) or string.match(bufname, pattern) then
                match_found = true
            end
        end)
        if match_found then
            return true
        end
    end
    return false
end

local function is_floating_window_excluded(bufnr, bufname)
    local winid = vim.fn.bufwinid(bufnr)
    if winid == -1 then
        return false
    end

    local ok, win_config = pcall(vim.api.nvim_win_get_config, winid)
    if not ok or win_config.relative == "" then
        return false
    end

    if
        win_config.focusable == false
        or win_config.style == "minimal"
        or (win_config.width and win_config.width < MIN_POPUP_WIDTH)
        or (win_config.height and win_config.height < MIN_POPUP_HEIGHT)
    then
        return true
    end

    if bufname and bufname ~= "" then
        local popup_patterns = { "completion", "hover", "signature", "diagnostic" }
        for _, popup_pattern in ipairs(popup_patterns) do
            if string.match(bufname:lower(), popup_pattern) then
                return true
            end
        end
    end

    return false
end

-- Public: check if buffer should be excluded from completions
function M.is_buffer_excluded(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    if not bufnr or bufnr < 0 or not vim.api.nvim_buf_is_valid(bufnr) then
        return true
    end

    local cached_result = exclusion_cache[bufnr]
    if cached_result ~= nil then
        return cached_result
    end

    if not config.enabled then
        exclusion_cache[bufnr] = true
        return true
    end

    local ok_filetype, filetype = pcall(function()
        return vim.bo[bufnr].filetype
    end)
    if not ok_filetype then
        exclusion_cache[bufnr] = true
        return true
    end

    local buftype = ""
    local bufname = ""
    pcall(function()
        buftype = vim.bo[bufnr].buftype
        bufname = vim.api.nvim_buf_get_name(bufnr)
    end)

    if is_filetype_excluded(filetype) then
        exclusion_cache[bufnr] = true
        return true
    end
    if is_buftype_excluded(buftype) then
        exclusion_cache[bufnr] = true
        return true
    end
    if is_buffer_name_excluded(bufname) then
        exclusion_cache[bufnr] = true
        return true
    end
    if is_floating_window_excluded(bufnr, bufname) then
        exclusion_cache[bufnr] = true
        return true
    end

    exclusion_cache[bufnr] = false
    return false
end

-- Build FIM (fill-in-middle) context from the current buffer
function M.get_fim_context_enhanced()
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1] - 1
    local col = cursor[2]

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local filetype = get_buffer_language()
    local workspace_root = find_workspace_root()
    local relative_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")

    local total_lines = #lines
    if total_lines == 0 then
        return {
            prefix = "",
            suffix = "",
            filetype = filetype,
            relative_path = relative_path,
            workspace_root = workspace_root,
        }
    end

    local context_size = math.min(
        CONTEXT_MAX_LINES,
        math.max(CONTEXT_MIN_LINES, math.floor(total_lines / CONTEXT_SIZE_RATIO))
    )
    local start_line = math.max(0, row - context_size)
    local end_line = math.min(total_lines - 1, row + context_size)

    -- Build prefix
    local prefix_lines = {}
    for i = start_line + 1, row do
        table.insert(prefix_lines, lines[i] or "")
    end

    if row + 1 <= total_lines then
        local current_line = lines[row + 1] or ""
        local line_prefix = string.sub(current_line, 1, col)
        if #prefix_lines > 0 then
            table.insert(prefix_lines, line_prefix)
        else
            prefix_lines[1] = line_prefix
        end
    end

    -- Build suffix
    local suffix_lines = {}
    if row + 1 <= total_lines then
        local current_line = lines[row + 1] or ""
        local line_suffix = string.sub(current_line, col + 1)
        if line_suffix ~= "" then
            table.insert(suffix_lines, line_suffix)
        end
    end
    for i = row + 2, math.min(end_line + 1, total_lines) do
        table.insert(suffix_lines, lines[i] or "")
    end

    return {
        prefix = table.concat(prefix_lines, "\n"),
        suffix = table.concat(suffix_lines, "\n"),
        filetype = filetype,
        relative_path = relative_path,
        workspace_root = workspace_root,
    }
end

-- HTTP request wrapper
local function make_request(data, callback)
    local auth = require("mistral-codestral.auth")
    local http_client = require("mistral-codestral.http_client")
    local api_key = auth.get_api_key()

    if not api_key then
        callback(
            nil,
            "API key not found. Set CODESTRAL_API_KEY env var, MISTRAL_API_KEY, or pass api_key in setup()"
        )
        return
    end

    http_client.post("https://codestral.mistral.ai/v1/fim/completions", {
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. api_key,
        },
        data = data,
        timeout = config.timeout,
    }, callback)
end

-- Public: request a FIM completion
function M.request_completion(callback, context_override)
    local context = context_override or M.get_fim_context_enhanced()

    local request_data = {
        model = config.model,
        prompt = context.prefix,
        suffix = context.suffix,
        max_tokens = config.max_tokens,
        temperature = config.temperature,
        stop = config.stop_tokens,
    }

    make_request(request_data, function(response, error)
        if error then
            debug_log("Mistral Codestral error: " .. error, vim.log.levels.ERROR)
            callback(nil)
            return
        end

        if response and response.choices and response.choices[1] then
            local choice = response.choices[1]
            local completion = choice.text or (choice.message and choice.message.content)
            callback(completion)
        else
            callback(nil)
        end
    end)
end

-- Public: insert a completion at the cursor
function M.insert_completion(completion)
    if not completion or completion == "" then
        return
    end

    vim.schedule(function()
        local cursor = vim.api.nvim_win_get_cursor(0)
        local row = cursor[1] - 1
        local col = cursor[2]
        local bufnr = vim.api.nvim_get_current_buf()

        local completion_lines = vim.split(completion, "\n", { plain = true })

        if #completion_lines == 1 then
            vim.api.nvim_put({ completion_lines[1] }, "c", true, true)
        else
            local current_line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
            local line_prefix = string.sub(current_line, 1, col)
            local line_suffix = string.sub(current_line, col + 1)

            local new_lines = { line_prefix .. completion_lines[1] }
            for i = 2, #completion_lines - 1 do
                table.insert(new_lines, completion_lines[i])
            end
            if #completion_lines > 1 then
                table.insert(new_lines, completion_lines[#completion_lines] .. line_suffix)
            end

            vim.api.nvim_buf_set_lines(bufnr, row, row + 1, false, new_lines)

            local final_row = row + #completion_lines - 1
            local final_col = (#completion_lines == 1)
                and (col + string.len(completion_lines[1]))
                or string.len(completion_lines[#completion_lines])

            local final_line = vim.api.nvim_buf_get_lines(bufnr, final_row, final_row + 1, false)[1] or ""
            final_col = math.min(final_col, string.len(final_line))

            vim.api.nvim_win_set_cursor(0, { final_row + 1, final_col })
        end
    end)
end

-- Manual trigger for completion (useful for testing or virtual text)
local function complete()
    M.request_completion(function(completion)
        if completion then
            M.insert_completion(completion)
        end
    end)
end

-- Plugin setup
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", default_config, user_config or {})

    setup_cache_invalidation()

    if not validate_exclusion_patterns() then
        vim.notify("Some exclusion patterns are invalid. Check configuration.", vim.log.levels.WARN)
    end

    debug_log("Mistral Codestral fork setup complete (debug=" .. tostring(config.debug) .. ")")

    -- Initialize auth module
    require("mistral-codestral.auth").setup(config.auth)

    -- Optional virtual-text ghost preview
    if config.virtual_text.enabled then
        local ok, virtual_text = pcall(require, "mistral-codestral.virtual_text")
        if ok then
            virtual_text.setup(config)
        else
            debug_log("Failed to load virtual_text module: " .. tostring(virtual_text), vim.log.levels.WARN)
        end
    end

    -- User commands
    vim.api.nvim_create_user_command("MistralCodestralComplete", complete, {
        desc = "Get code completion from Mistral Codestral",
    })

    vim.api.nvim_create_user_command("MistralCodestralToggle", function()
        config.enabled = not config.enabled
        vim.notify(
            "Mistral Codestral " .. (config.enabled and "enabled" or "disabled"),
            vim.log.levels.INFO
        )
    end, {
        desc = "Toggle Mistral Codestral completions",
    })
end

-- Public exports
M.complete = complete
M.config = function()
    return config
end
M.uv = uv

return M
