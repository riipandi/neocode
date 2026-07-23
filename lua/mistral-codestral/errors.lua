-- lua/mistral-codestral/errors.lua
-- Centralized error reporting.

local M = {}

M.SEVERITY = {
    ERROR = "error",
    WARNING = "warning",
    INFO = "info",
    DEBUG = "debug",
}

M.CATEGORY = {
    API = "api",
    AUTH = "auth",
    CONFIG = "config",
    NETWORK = "network",
    INTERNAL = "internal",
}

local config = {
    debug = false,
    log_file = nil,
    notify_errors = true,
}

function M.setup(opts)
    config = vim.tbl_extend("force", config, opts or {})
end

local function format_error(category, message, context)
    local parts = { "[mistral-codestral]" }
    if category then
        table.insert(parts, "[" .. category .. "]")
    end
    table.insert(parts, message)
    if context and next(context) then
        local context_str = vim.inspect(context):gsub("\n", " ")
        table.insert(parts, "Context: " .. context_str)
    end
    return table.concat(parts, " ")
end

local function log_to_file(severity, message)
    if not config.log_file then
        return
    end
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local entry = string.format("[%s] [%s] %s\n", timestamp, severity:upper(), message)
    local f = io.open(config.log_file, "a")
    if f then
        f:write(entry)
        f:close()
    end
end

function M.report(severity, category, message, context)
    local formatted = format_error(category, message, context)
    log_to_file(severity, formatted)

    if severity == M.SEVERITY.DEBUG and not config.debug then
        return
    end

    if config.notify_errors then
        local level = vim.log.levels.INFO
        if severity == M.SEVERITY.ERROR then
            level = vim.log.levels.ERROR
        elseif severity == M.SEVERITY.WARNING then
            level = vim.log.levels.WARN
        end
        vim.notify(formatted, level)
    end
end

function M.error(category, message, context)
    M.report(M.SEVERITY.ERROR, category, message, context)
end

function M.warning(category, message, context)
    M.report(M.SEVERITY.WARNING, category, message, context)
end

function M.info(category, message, context)
    M.report(M.SEVERITY.INFO, category, message, context)
end

function M.debug(category, message, context)
    M.report(M.SEVERITY.DEBUG, category, message, context)
end

-- Parse API error responses (Mistral / FastAPI style)
function M.parse_api_error(response)
    if not response then
        return "Empty API response"
    end
    if response.error then
        local msg = "API Error"
        if response.error.type then
            msg = msg .. " (" .. response.error.type .. ")"
        end
        if response.error.message then
            msg = msg .. ": " .. response.error.message
        end
        return msg
    end
    if response.detail then
        local msg = "Validation Error"
        if type(response.detail) == "string" then
            return msg .. ": " .. response.detail
        elseif type(response.detail) == "table" and response.detail[1] then
            return msg .. ": " .. (response.detail[1].msg or "Invalid request")
        end
    end
    return nil
end

-- Translate curl exit code → human-readable error
function M.parse_http_error(exit_code, timeout)
    if exit_code == 28 then
        return string.format("Request timeout after %d seconds", math.floor(timeout / 1000))
    elseif exit_code == 6 then
        return "Could not resolve host (check network connection)"
    elseif exit_code == 7 then
        return "Failed to connect to server"
    elseif exit_code == 35 then
        return "SSL connection error"
    elseif exit_code == 52 then
        return "Server returned nothing (empty response)"
    elseif exit_code == 56 then
        return "Network error receiving data"
    elseif exit_code == 60 then
        return "SSL certificate problem"
    elseif exit_code == 22 then
        return "HTTP error response (4xx/5xx)"
    else
        return string.format("Request failed (curl exit %d)", exit_code)
    end
end

return M
