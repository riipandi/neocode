-- lua/mistral-codestral/auth.lua
-- API key retrieval for Mistral Codestral.
-- Forked to prioritize CODESTRAL_API_KEY env var (per project requirement)
-- and to drop the interactive prompt + encrypted file complexity.

local M = {}

local uv = vim.uv or vim.loop

-- Default authentication configuration
local default_auth_config = {
    -- Order matters: first method that yields a key wins.
    methods = {
        "environment", -- env vars (CODESTRAL_API_KEY first)
        "keyring", -- system keyring
        "config", -- explicit api_key passed to setup()
    },

    -- Keyring configuration
    keyring = {
        service = "mistral-codestral-nvim",
        username = vim.env.USER or "default",
    },

    -- Environment variable names to check, in priority order.
    -- CODESTRAL_API_KEY is the project-mandated variable.
    env_vars = {
        "CODESTRAL_API_KEY",
        "MISTRAL_API_KEY",
        "MISTRAL_CODESTRAL_API_KEY",
    },

    -- Validation
    validate_on_startup = false,
    cache_validation = true,
    validation_timeout = 5000, -- ms
}

local auth_config = {}
local api_key_cache = nil
local validation_cache = {}

local function ensure_initialized()
    if not auth_config.methods then
        auth_config = vim.tbl_deep_extend("force", default_auth_config, {})
    end
end

local function log_debug(msg)
    if auth_config.debug then
        vim.notify("[Mistral Auth] " .. msg, vim.log.levels.DEBUG)
    end
end

local function log_info(msg)
    vim.notify("[Mistral Auth] " .. msg, vim.log.levels.INFO)
end

local function log_warn(msg)
    vim.notify("[Mistral Auth] " .. msg, vim.log.levels.WARN)
end

-- Sanitize API key for logging
local function sanitize_api_key(key)
    if not key or type(key) ~= "string" then
        return "[INVALID]"
    end
    if #key < 8 then
        return "[TOO_SHORT]"
    end
    return key:sub(1, 4) .. "..." .. key:sub(-4)
end

-- Check if a command exists in PATH
local function command_exists(cmd)
    if not cmd:match("^[a-zA-Z0-9_-]+$") then
        return false
    end
    local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
    if not handle then
        return false
    end
    local result = handle:read("*a")
    handle:close()
    return result and result ~= ""
end

-- Method: env var
local function get_from_environment()
    ensure_initialized()
    for _, var_name in ipairs(auth_config.env_vars) do
        local key = vim.env[var_name]
        if key and key ~= "" then
            log_debug("Found API key in env var: " .. var_name)
            return key
        end
    end
    return nil
end

-- Method: explicit api_key in setup config (supports `cmd:...` shell)
local function get_from_config()
    local ok, mistral = pcall(require, "mistral-codestral")
    if not ok then
        return nil
    end
    local mistral_config = mistral.config()
    if not mistral_config or not mistral_config.api_key then
        return nil
    end

    local api_key = mistral_config.api_key
    if type(api_key) ~= "string" then
        return nil
    end

    if api_key:match("^cmd:") then
        local command = api_key:sub(5)
        if vim.system then
            local result = vim.system({ "sh", "-c", command }, { text = true }):wait()
            if result.code == 0 and result.stdout then
                return vim.trim(result.stdout)
            end
        end
        return nil
    end

    return api_key
end

-- Method: system keyring (macOS keychain, Linux secret-tool, Python keyring)
local function get_from_keyring()
    if
        not command_exists("security")
        and not command_exists("secret-tool")
        and not command_exists("keyring")
    then
        log_debug("No keyring tools available (security/secret-tool/keyring)")
        return nil
    end

    local service = auth_config.keyring.service
    local username = auth_config.keyring.username

    -- Build candidate commands
    local commands = {}
    if command_exists("security") then
        table.insert(
            commands,
            { "security", "find-generic-password", "-s", service, "-a", username, "-w" }
        )
    end
    if command_exists("secret-tool") then
        table.insert(
            commands,
            { "secret-tool", "lookup", "service", service, "username", username }
        )
    end
    if command_exists("keyring") then
        table.insert(commands, { "keyring", "get", service, username })
    end

    for _, cmd in ipairs(commands) do
        if vim.system then
            local result = vim.system(cmd, { text = true }):wait()
            if result.code == 0 and result.stdout and result.stdout:match("%S") then
                return (result.stdout:gsub("%s+", ""))
            end
        end
    end

    log_debug("No API key found in system keyring")
    return nil
end

-- Save API key to keyring (best-effort)
function M.save_to_keyring(api_key)
    local service = auth_config.keyring.service
    local username = auth_config.keyring.username

    if command_exists("security") and vim.system then
        local result = vim.system({
            "security",
            "add-generic-password",
            "-s",
            service,
            "-a",
            username,
            "-w",
            api_key,
            "-U",
        }, { text = true }):wait()
        if result.code == 0 then
            log_info("API key saved to macOS keychain")
            return true
        end
    end

    if command_exists("secret-tool") and vim.system then
        local result = vim.system({
            "secret-tool",
            "store",
            "--label=Mistral Codestral API Key",
            "service",
            service,
            "username",
            username,
        }, { text = true, stdin = api_key }):wait()
        if result.code == 0 then
            log_info("API key saved to secret-tool")
            return true
        end
    end

    if command_exists("keyring") and vim.system then
        local result = vim.system({ "keyring", "set", service, username }, { text = true, stdin = api_key }):wait()
        if result.code == 0 then
            log_info("API key saved to python-keyring")
            return true
        end
    end

    log_warn("Failed to save API key to keyring (no compatible tool found)")
    return false
end

-- Public: retrieve API key
function M.get_api_key()
    ensure_initialized()

    if api_key_cache then
        return api_key_cache
    end

    log_debug("Retrieving API key using methods: " .. table.concat(auth_config.methods, ", "))

    for _, method in ipairs(auth_config.methods) do
        local key
        if method == "environment" then
            key = get_from_environment()
        elseif method == "keyring" then
            key = get_from_keyring()
        elseif method == "config" then
            key = get_from_config()
        end

        if key and key ~= "" then
            api_key_cache = key
            log_debug("Resolved API key via: " .. method .. " (" .. sanitize_api_key(key) .. ")")
            return key
        end
    end

    log_warn("No API key found. Set CODESTRAL_API_KEY env var or pass api_key to setup()")
    return nil
end

-- Validate API key by hitting the API with a minimal request
function M.validate_api_key(api_key, callback)
    ensure_initialized()

    if not api_key then
        callback(false, "No API key provided")
        return
    end

    local cache_key = vim.fn.sha256(api_key)
    local cached = validation_cache[cache_key]
    if cached and auth_config.cache_validation then
        local age = uv.now() - cached.timestamp
        if age < auth_config.validation_timeout then
            callback(cached.valid, cached.error)
            return
        end
    end

    local http_client = require("mistral-codestral.http_client")
    http_client.validate_api_key(api_key, function(valid, error_msg)
        validation_cache[cache_key] = {
            valid = valid,
            error = error_msg,
            timestamp = uv.now(),
        }
        callback(valid, error_msg)
    end)
end

-- Clear cached API key
function M.clear_cache()
    api_key_cache = nil
    validation_cache = {}
end

-- Get the auth method that would resolve (env, keyring, config)
function M.get_current_method()
    ensure_initialized()
    for _, method in ipairs(auth_config.methods) do
        local key
        if method == "environment" then
            key = get_from_environment()
        elseif method == "keyring" then
            key = get_from_keyring()
        elseif method == "config" then
            key = get_from_config()
        end
        if key and key ~= "" then
            return method
        end
    end
    return "none"
end

-- :MistralCodestralAuth subcommand handler
function M.auth_command(args)
    local subcommand = args.fargs[1] or "status"

    if subcommand == "status" then
        local key = M.get_api_key()
        if key then
            log_info("API key configured (method: " .. M.get_current_method() .. ")")
        else
            log_warn("No API key configured. Set CODESTRAL_API_KEY env var.")
        end
    elseif subcommand == "set" then
        local key = vim.fn.inputsecret("Enter your Mistral API key: ")
        if key and key ~= "" then
            local choice = vim.fn.confirm(
                "Where to save?",
                "&Keyring\n&Skip (env var only)",
                1
            )
            if choice == 1 then
                M.save_to_keyring(key)
            end
            M.clear_cache()
        end
    elseif subcommand == "clear" then
        M.clear_cache()
        log_info("Cache cleared")
    elseif subcommand == "validate" then
        local key = M.get_api_key()
        if key then
            log_info("Validating API key...")
            M.validate_api_key(key, function(valid, err)
                if valid then
                    log_info("API key is valid")
                else
                    log_warn("API key is invalid: " .. (err or "unknown error"))
                end
            end)
        else
            log_warn("No API key to validate")
        end
    else
        log_warn("Unknown subcommand: " .. subcommand .. " (use: status, set, clear, validate)")
    end
end

function M.setup(user_config)
    auth_config = vim.tbl_deep_extend("force", default_auth_config, user_config or {})

    vim.api.nvim_create_user_command("MistralCodestralAuth", M.auth_command, {
        nargs = "?",
        complete = function()
            return { "status", "set", "clear", "validate" }
        end,
        desc = "Manage Mistral Codestral authentication",
    })

    if auth_config.validate_on_startup then
        vim.defer_fn(function()
            local key = M.get_api_key()
            if key then
                M.validate_api_key(key, function(valid, err)
                    if not valid then
                        log_warn("Startup validation failed: " .. (err or "unknown"))
                    end
                end)
            end
        end, 1500)
    end
end

return M
