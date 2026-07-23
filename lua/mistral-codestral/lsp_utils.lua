-- lua/mistral-codestral/lsp_utils.lua
-- LSP-aware context enrichment.
-- Replaces the deprecated nvim-treesitter.ts_utils with vim.treesitter.get_node().

local M = {}
local errors = require("mistral-codestral.errors")

local uv = vim.uv or vim.loop

-- Cache LSP clients per-buffer for ~100ms
local client_cache = {
    bufnr = nil,
    clients = nil,
    timestamp = 0,
}
local CACHE_TTL = 100

local function get_cached_clients(bufnr)
    local now = uv.now()
    if
        client_cache.bufnr == bufnr
        and client_cache.clients
        and (now - client_cache.timestamp) < CACHE_TTL
    then
        return client_cache.clients
    end

    local ok, clients = pcall(vim.lsp.get_clients, { bufnr = bufnr })
    if not ok then
        errors.warning(errors.CATEGORY.INTERNAL, "Failed to get LSP clients", { error = clients })
        return {}
    end

    client_cache.bufnr = bufnr
    client_cache.clients = clients or {}
    client_cache.timestamp = now
    return client_cache.clients
end

function M.clear_cache()
    client_cache.bufnr = nil
    client_cache.clients = nil
    client_cache.timestamp = 0
end

-- Categorize diagnostics for context
local function get_lsp_diagnostics()
    local bufnr = vim.api.nvim_get_current_buf()
    local ok, diagnostics = pcall(vim.diagnostic.get, bufnr)
    if not ok or not diagnostics then
        return { errors = {}, warnings = {}, hints = {} }
    end

    local info = { errors = {}, warnings = {}, hints = {} }
    for _, d in ipairs(diagnostics) do
        local entry = { line = d.lnum + 1, message = d.message, source = d.source }
        if d.severity == vim.diagnostic.severity.ERROR then
            table.insert(info.errors, entry)
        elseif d.severity == vim.diagnostic.severity.WARN then
            table.insert(info.warnings, entry)
        elseif d.severity == vim.diagnostic.severity.HINT then
            table.insert(info.hints, entry)
        end
    end
    return info
end

-- Determine cursor context using native vim.treesitter (no nvim-treesitter dependency)
function M.get_cursor_context()
    local context = {
        in_function = false,
        in_class = false,
        in_comment = false,
        in_string = false,
    }

    -- vim.treesitter is built-in on Neovim 0.9+
    if not vim.treesitter then
        return context
    end

    -- Prefer get_node({ pos }) which is the modern, non-deprecated API
    local node
    local ok = pcall(function()
        node = vim.treesitter.get_node()
    end)
    if not ok or not node then
        return context
    end

    while node do
        local t = node:type()
        if t:match("function") or t:match("method") then
            context.in_function = true
        end
        if t:match("class") or t:match("struct") or t:match("trait") or t:match("impl") then
            context.in_class = true
        end
        if t:match("comment") then
            context.in_comment = true
        end
        if t:match("string") then
            context.in_string = true
        end
        node = node:parent()
    end

    return context
end

-- Detect imports/dependencies from the top of the buffer
local function get_imports_context()
    local bufnr = vim.api.nvim_get_current_buf()
    local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, 0, 50, false)
    if not ok or not lines then
        return {}
    end

    local imports = {}
    local filetype = vim.bo.filetype

    for _, line in ipairs(lines) do
        if filetype == "python" then
            if line:match("^import%s+") or line:match("^from%s+") then
                table.insert(imports, line)
            end
        elseif filetype == "javascript" or filetype == "typescript" or filetype == "javascriptreact" or filetype == "typescriptreact" then
            if line:match("^import") or line:match("^const%s.+=%s+require") or line:match("^export%s+") then
                table.insert(imports, line)
            end
        elseif filetype == "rust" then
            if line:match("^use%s+") or line:match("^extern%s+crate") then
                table.insert(imports, line)
            end
        elseif filetype == "go" then
            if line:match("^import") or line:match('^%s+"') then
                table.insert(imports, line)
            end
        end
    end

    return imports
end

-- Build the enhanced context for a completion request
function M.get_enhanced_context()
    local base_context = require("mistral-codestral").get_fim_context_enhanced()

    local cursor_context = M.get_cursor_context()
    local imports = get_imports_context()
    local diagnostics = get_lsp_diagnostics()

    -- Enrich prefix with minimal, high-signal context
    local enhanced_prefix = base_context.prefix
    if #imports > 0 then
        enhanced_prefix = "// Imports:\n" .. table.concat(imports, "\n") .. "\n\n" .. enhanced_prefix
    end
    if cursor_context.in_class then
        enhanced_prefix = "// Inside class/struct\n" .. enhanced_prefix
    end
    if cursor_context.in_function then
        enhanced_prefix = "// Inside function/method\n" .. enhanced_prefix
    end
    if cursor_context.in_comment then
        enhanced_prefix = "// Inside comment\n" .. enhanced_prefix
    end

    return vim.tbl_extend("force", base_context, {
        prefix = enhanced_prefix,
        diagnostics = diagnostics,
        cursor_context = cursor_context,
        imports = imports,
    })
end

-- Fetch LSP hover content for the current symbol (optional, not used by default)
function M.get_hover_info(callback)
    if type(callback) ~= "function" then
        return
    end
    local ok, params = pcall(vim.lsp.util.make_position_params)
    if not ok then
        callback(nil)
        return
    end
    vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
        if err or not result or not result.contents then
            callback(nil)
            return
        end
        local content = ""
        if type(result.contents) == "string" then
            content = result.contents
        elseif result.contents.value then
            content = result.contents.value
        end
        callback(content)
    end)
end

return M
