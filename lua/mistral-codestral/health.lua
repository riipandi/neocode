-- lua/mistral-codestral/health.lua
-- Health check for the Mistral Codestral plugin (forked).
-- blink.cmp-only; no nvim-cmp / nvim-treesitter references.

local M = {}

local function check_binary(name, command)
    if not command:match("^[a-zA-Z0-9_-]+$") then
        vim.health.error(name .. " has invalid command name")
        return false
    end
    local handle = io.popen("command -v " .. command .. " 2>/dev/null")
    if not handle then
        vim.health.warn(name .. ": could not execute `which`")
        return false
    end
    local result = handle:read("*a")
    handle:close()
    if result and result ~= "" then
        vim.health.ok(name .. " available at: " .. result:gsub("\n", ""))
        return true
    end
    vim.health.error(name .. " not found in PATH")
    return false
end

local function is_provider_registered()
    -- 1) Try the user-facing config (set via blink.cmp.setup in the user's config)
    local ok, blink = pcall(require, "blink.cmp")
    if ok and blink.get_config then
        local cfg = blink.get_config()
        if cfg and cfg.sources and cfg.sources.providers and cfg.sources.providers.mistral_codestral then
            return true
        end
    end
    -- 2) Try the runtime config (set via add_source_provider)
    local ok2, runtime = pcall(require, "blink.cmp.config")
    if ok2 and runtime and runtime.sources and runtime.sources.providers then
        return runtime.sources.providers.mistral_codestral ~= nil
    end
    return false
end

function M.check()
    vim.health.start("mistral-codestral (fork)")

    -- Neovim version
    local nvim_version = vim.version()
    local version_string = string.format(
        "%d.%d.%d",
        nvim_version.major,
        nvim_version.minor,
        nvim_version.patch or 0
    )
    if vim.fn.has("nvim-0.10.0") == 1 then
        vim.health.ok("Neovim " .. version_string .. " (vim.uv + vim.json + vim.system available)")
    elseif vim.fn.has("nvim-0.9.0") == 1 then
        vim.health.warn(
            "Neovim " .. version_string .. " — some features may fall back (vim.uv missing?)"
        )
    else
        vim.health.error("Neovim >= 0.9.0 required, current: " .. version_string)
    end

    -- System deps
    vim.health.start("System Dependencies")
    check_binary("curl", "curl")

    -- HTTP client module
    vim.health.start("HTTP Client")
    local http_ok, http_client = pcall(require, "mistral-codestral.http_client")
    if http_ok then
        vim.health.ok("http_client loaded")
        if type(http_client.post) == "function" and type(http_client.validate_api_key) == "function" then
            vim.health.ok("post() and validate_api_key() available")
        else
            vim.health.error("http_client missing required functions")
        end
    else
        vim.health.error("http_client failed to load: " .. tostring(http_client))
    end

    -- Auth
    vim.health.start("Authentication")
    local auth_ok, auth = pcall(require, "mistral-codestral.auth")
    if auth_ok then
        vim.health.ok("auth module loaded")
        local api_key = auth.get_api_key()
        if api_key and api_key ~= "" then
            local method = auth.get_current_method()
            vim.health.ok("API key found (length: " .. #api_key .. ")")
            vim.health.info("Resolved via: " .. method)
            if method == "environment" then
                local env_used = nil
                for _, var in ipairs({ "CODESTRAL_API_KEY", "MISTRAL_API_KEY", "MISTRAL_CODESTRAL_API_KEY" }) do
                    if vim.env[var] and vim.env[var] ~= "" then
                        env_used = var
                        break
                    end
                end
                if env_used then
                    vim.health.info("Environment variable: " .. env_used)
                end
            end
        else
            vim.health.error("No API key configured", {
                "Set CODESTRAL_API_KEY environment variable (recommended)",
                "Or set MISTRAL_API_KEY",
                "Or pass api_key in setup()",
                "Or run :MistralCodestralAuth set",
            })
        end
    else
        vim.health.error("auth module failed to load: " .. tostring(auth))
    end

    -- Plugin config
    vim.health.start("Plugin Configuration")
    local ok, mistral = pcall(require, "mistral-codestral")
    if ok then
        local cfg = mistral.config()
        if cfg then
            vim.health.ok("Plugin configured")
            vim.health.info("Model: " .. (cfg.model or "not set"))
            vim.health.info("Max tokens: " .. (cfg.max_tokens or "not set"))
            vim.health.info("Virtual text enabled: " .. tostring(cfg.virtual_text and cfg.virtual_text.enabled))
            vim.health.info("Max items per completion: " .. tostring(cfg.max_items))
        else
            vim.health.warn("Plugin loaded but not yet configured (call setup())")
        end
    else
        vim.health.error("Plugin failed to load: " .. tostring(mistral))
    end

    -- blink.cmp integration
    vim.health.start("blink.cmp Integration")
    local blink_ok, blink = pcall(require, "blink.cmp")
    if blink_ok then
        vim.health.ok("blink.cmp is available")
        if is_provider_registered() then
            vim.health.ok("mistral_codestral provider registered in blink.cmp")
        else
            vim.health.info(
                "mistral_codestral provider not yet registered — call plugin_mistral_codestral.lua "
                .. "or add `sources.providers.mistral_codestral` to your blink.cmp config"
            )
        end

        -- Check if the provider is in the default sources list (user may have customized it)
        if blink.get_config then
            local cfg = blink.get_config()
            if cfg and cfg.sources and cfg.sources.default then
                local in_default = false
                for _, src in ipairs(cfg.sources.default) do
                    if src == "mistral_codestral" then
                        in_default = true
                        break
                    end
                end
                if in_default then
                    vim.health.ok("mistral_codestral is in default sources")
                else
                    vim.health.info(
                        "mistral_codestral not in default sources (add it to sources.default to enable)"
                    )
                end
            end
        end
    else
        vim.health.error("blink.cmp not available", {
            "Install blink.cmp — this fork does not support nvim-cmp",
        })
    end

    -- Treesitter (optional, for context detection)
    vim.health.start("Treesitter (optional)")
    if vim.treesitter and vim.treesitter.get_node then
        vim.health.ok("Native vim.treesitter available (no nvim-treesitter dependency)")
    else
        vim.health.info("vim.treesitter.get_node not available — cursor-context heuristics will be limited")
    end
end

return M
