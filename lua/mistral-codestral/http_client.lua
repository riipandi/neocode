-- lua/mistral-codestral/http_client.lua
-- Centralized curl-based HTTP client.
-- Uses vim.json (Neovim 0.10+ native) instead of vim.fn.json_encode/decode
-- for ~2-3x faster JSON round-trips.

local M = {}
local errors = require("mistral-codestral.errors")

local uv = vim.uv or vim.loop

-- JSON encode using the fast native API
local function json_encode(data)
    if vim.json and vim.json.encode then
        return vim.json.encode(data)
    end
    return vim.fn.json_encode(data)
end

local function json_decode(text)
    if vim.json and vim.json.decode then
        return vim.json.decode(text)
    end
    return vim.fn.json_decode(text)
end

-- POST a JSON request. Callback signature: function(response, error)
function M.post(url, options, callback)
    options = options or {}
    local headers = options.headers or {}
    local data = options.data
    local timeout = options.timeout or 10000

    local ok, json_data = pcall(json_encode, data)
    if not ok then
        errors.error(errors.CATEGORY.INTERNAL, "Failed to encode request body", { err = tostring(json_data) })
        callback(nil, "JSON encode failed: " .. tostring(json_data))
        return
    end

    -- Write body to a temp file (avoids argv size limits + quoting issues)
    local temp_file = vim.fn.tempname()
    local f = io.open(temp_file, "w")
    if not f then
        errors.error(errors.CATEGORY.INTERNAL, "Cannot create temp file for request body")
        callback(nil, "Failed to create temp file")
        return
    end
    f:write(json_data)
    f:close()

    -- Build curl argv (avoids shell injection — no string interpolation)
    local curl_cmd = {
        "curl",
        "-s",
        "-S",
        "-X",
        "POST",
        "-d",
        "@" .. temp_file,
        "--max-time",
        tostring(math.max(1, math.floor(timeout / 1000))),
    }

    for key, value in pairs(headers) do
        table.insert(curl_cmd, "-H")
        table.insert(curl_cmd, key .. ": " .. value)
    end
    table.insert(curl_cmd, url)

    -- Fire the request
    local job_id = vim.fn.jobstart(curl_cmd, {
        on_exit = function(_, exit_code)
            pcall(vim.fn.delete, temp_file)
            if exit_code ~= 0 then
                local error_msg = errors.parse_http_error(exit_code, timeout)
                errors.warning(errors.CATEGORY.NETWORK, error_msg, { exit_code = exit_code })
                callback(nil, error_msg)
            end
        end,
        stdout_buffered = true,
        on_stdout = function(_, output_data)
            if not output_data or not output_data[1] or output_data[1] == "" then
                return
            end
            local response_text = table.concat(output_data, "\n")
            local ok_decode, response = pcall(json_decode, response_text)
            if not ok_decode or not response then
                errors.error(errors.CATEGORY.API, "Failed to parse JSON response",
                    { snippet = response_text:sub(1, 200) })
                callback(nil, "Failed to parse JSON response")
                return
            end
            local api_error = errors.parse_api_error(response)
            if api_error then
                errors.error(errors.CATEGORY.API, api_error)
                callback(nil, api_error)
            else
                callback(response, nil)
            end
        end,
    })

    if job_id <= 0 then
        pcall(vim.fn.delete, temp_file)
        errors.error(errors.CATEGORY.INTERNAL, "Failed to start HTTP job", { job_id = job_id })
        callback(nil, "Failed to start HTTP request")
    end
end

-- Validate API key with a minimal FIM request
function M.validate_api_key(api_key, callback)
    if type(callback) ~= "function" then
        errors.error(errors.CATEGORY.INTERNAL, "validate_api_key requires a callback")
        return
    end

    if not api_key then
        callback(false, "No API key provided")
        return
    end

    M.post("https://codestral.mistral.ai/v1/fim/completions", {
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. api_key,
        },
        data = {
            model = "codestral-latest",
            prompt = "test",
            max_tokens = 1,
            temperature = 0.0,
        },
        timeout = 5000,
    }, function(response, error)
        if error then
            callback(false, error)
            return
        end
        if response then
            callback(true, nil)
        else
            callback(false, "Invalid response")
        end
    end)
end

return M
