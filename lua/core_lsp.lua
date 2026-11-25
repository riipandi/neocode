-- ============================================================================
-- Core LSP Configuration
-- ============================================================================

local snacks = require "snacks"
local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Find the project root for a buffer. root_dir handlers receive
-- (bufnr, on_dir) from vim.lsp.config, so the argument is a buffer number.
local function buffer_root(bufnr, patterns)
    local name = type(bufnr) == "number" and vim.api.nvim_buf_get_name(bufnr)
        or tostring(bufnr)
    local dir = (name ~= "" and vim.fs.dirname(name)) or vim.fn.getcwd()
    local path = dir
    for _, pattern in ipairs(patterns) do
        local found = vim.fn.finddir(pattern, path .. ";")
        if found ~= "" then
            return vim.fn.fnamemodify(found, ":h")
        end
        found = vim.fn.findfile(pattern, path .. ";")
        if found ~= "" then
            return vim.fn.fnamemodify(found, ":h")
        end
    end
    return dir
end

-- ============================================================================
-- LSP Server Configuration
-- ============================================================================
-- Servers are configured once with vim.lsp.config() and started with
-- vim.lsp.enable(). A FileType autocmd that also calls vim.lsp.start() would
-- spawn a second client for the same buffer (bashls#1 + bashls#2).

-- Shell script LSP (bash-language-server)
vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" },
    filetypes = { "sh", "bash", "zsh" },
    root_dir = function(bufnr, on_dir)
        on_dir(buffer_root(bufnr, { ".git", "Makefile" }))
    end,
    settings = {
        bashIde = {
            globPattern = "*@(.sh|.inc|.bash|.command)",
        },
    },
})

-- Python LSP (pylsp)
vim.lsp.config("pylsp", {
    cmd = { "pylsp" },
    filetypes = { "python" },
    root_dir = function(bufnr, on_dir)
        on_dir(buffer_root(bufnr, {
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            ".git",
        }))
    end,
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = false },
                flake8 = { enabled = true },
                black = { enabled = true },
            },
        },
    },
})

-- HTML LSP (superhtml). Configured, but only enabled when the binary exists.
local superhtml = vim.fn.executable "superhtml" == 1
if superhtml then
    vim.lsp.config("superhtml", {
        cmd = { "superhtml", "lsp" },
        filetypes = { "html", "shtml", "htm" },
    })
end

-- ============================================================================
-- LSP progress toast
-- ============================================================================
-- $/progress as one snacks toast per server (titled with the client name,
-- spinner icon, updated in place), so it looks like every other toast.
local progress = vim.defaulttable() -- client id -> list of { token, msg, done }
local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
vim.api.nvim_create_autocmd("LspProgress", {
    group = vim.api.nvim_create_augroup("lsp_progress_toast", { clear = true }),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local value = ev.data.params.value
        if not client or type(value) ~= "table" then return end

        local items = progress[client.id]
        local msg = ("[%3d%%] %s%s"):format(
            value.kind == "end" and 100 or value.percentage or 100,
            value.title or "",
            value.message and (" " .. value.message) or ""
        )
        for i = 1, #items + 1 do
            if i == #items + 1 or items[i].token == ev.data.params.token then
                items[i] = { token = ev.data.params.token, msg = msg, done = value.kind == "end" }
                break
            end
        end

        local lines = {}
        progress[client.id] = vim.tbl_filter(function(v)
            table.insert(lines, v.msg)
            return not v.done
        end, items)

        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, {
            id = "lsp_progress_" .. client.id,
            title = client.name,
            opts = function(notif)
                notif.icon = #progress[client.id] == 0 and " "
                    or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
        })
    end,
})

-- ============================================================================
-- Enable LSP servers (configured above / in language_*.lua)
-- ============================================================================

-- ============================================================================
-- Code Formatting
-- ============================================================================

-- Manual format of the current buffer through conform.nvim (same formatters
-- as format-on-save, including the LSP fallback).
local function format_buffer(opts)
    local conform = require "conform"
    local ok, err = pcall(
        conform.format,
        vim.tbl_extend("force", {
            async = false,
            timeout_ms = 2000,
            lsp_format = "fallback",
        }, opts or {})
    )
    local filetype = vim.bo.filetype
    if not ok then
        vim.notify(
            "Format failed: " .. tostring(err),
            vim.log.levels.ERROR,
            { title = "Format" }
        )
        return
    end
    local available = conform.list_formatters_to_run(0)
    if #available == 0 and not (filetype == "go" or filetype == "python") then
        vim.notify(
            "No formatter available for "
                .. (filetype ~= "" and filetype or "this buffer"),
            vim.log.levels.WARN,
            { title = "Format" }
        )
    end
end

vim.api.nvim_create_user_command("FormatCode", function()
    format_buffer()
end, {
    desc = "Format current buffer with conform.nvim",
})

-- <C-f> replaces the native page-down (<C-d> and the mouse wheel still scroll)
for _, lhs in ipairs({ "<leader>fm", "<C-f>" }) do
    snacks.keymap.set("n", lhs, function()
        format_buffer()
    end, { desc = "Format file" })
end

-- ============================================================================
-- LSP Keymaps
-- ============================================================================

autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
    callback = function(event)
        local opts = { buffer = event.buf }

        -- Dialog pickers (same layout as the buffer selector) instead of the
        -- quickfix window the builtins open for several results; a single
        -- result still jumps straight there.
        local lsp_pickers = {
            gd = { "lsp_definitions", "Go to definition" },
            grd = { "lsp_definitions", "Go to definition" },
            gD = { "lsp_declarations", "Go to declaration" },
            gs = { "lsp_declarations", "Go to declaration" },
            grr = { "lsp_references", "References" },
            gri = { "lsp_implementations", "Implementations" },
            grt = { "lsp_type_definitions", "Go to type definition" },
        }
        for lhs, picker in pairs(lsp_pickers) do
            snacks.keymap.set("n", lhs, function()
                Snacks.picker[picker[1]]({ layout = { preset = "buffers" }, prompt = " " })
            end, { buffer = event.buf, desc = picker[2] })
        end
        -- no bare `gr` (delays grr/grn/gra/gri/grt/grd) and no `gi` (native insert at last position; use `gri`)

        snacks.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        snacks.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

        snacks.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        snacks.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        snacks.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts)
        snacks.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts)
        snacks.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, opts)
        snacks.keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)
    end,
    desc = "LSP keymaps",
})

-- ============================================================================
-- Diagnostic Configuration
-- ============================================================================

vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = "if_many" },
    underline = { severity = vim.diagnostic.severity.ERROR },
    -- Gutter stays for errors and warnings only; info/hints would just add
    -- noise there (they still show as virtual text).
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
    } or {},
    virtual_text = {
        source = "if_many",
        spacing = 2,
    },
}

-- ============================================================================
-- Custom Commands
-- ============================================================================

vim.api.nvim_create_user_command("LspInfo", function()
    local clients = vim.lsp.get_clients { bufnr = 0 }
    if #clients == 0 then
        vim.notify(
            "No LSP clients attached to current buffer",
            vim.log.levels.WARN
        )
    else
        for _, client in ipairs(clients) do
            vim.notify(
                "LSP: " .. client.name .. " (ID: " .. client.id .. ")",
                vim.log.levels.INFO
            )
        end
    end
end, { desc = "Show LSP client info" })

-- ============================================================================
-- LSP window/showMessage Policy
-- ============================================================================
-- The default handler turns every window/showMessage into a bare vim.notify,
-- so servers that report build progress as Info messages (e.g. Expert's
-- "Engine is ready", "mix deps.get Building ...") spam unstyled toasts.
-- Policy: only Warning/Error become titled toasts; Info/Log stay in :LspLog.
vim.lsp.handlers["window/showMessage"] = function(_, params, ctx)
    if params.type <= vim.lsp.protocol.MessageType.Warning then
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        vim.notify(
            params.message,
            params.type == vim.lsp.protocol.MessageType.Error
                    and vim.log.levels.ERROR
                or vim.log.levels.WARN,
            {
                title = "LSP: "
                    .. (client and client.name or tostring(ctx.client_id)),
            }
        )
    end
end

-- ============================================================================
-- Enable LSP servers
-- ============================================================================

vim.lsp.config("lua_ls", {
    settings = { Lua = { completion = { callSnippet = "Replace" } } },
})

-- ts_ls, oxlint and tailwindcss: language_typescript.lua / language_tailwind.lua
-- Astro, buf, sqls, tofu_ls, zls: language_servers.lua
vim.lsp.enable {
    "bashls",
    "pylsp",
    -- "gopls",  -- managed by go.nvim (ray-x/go.nvim)
    "lua_ls",
    -- oxfmt LSP: formatting for the filetypes conform does not cover (html,
    -- css, yaml, toml, markdown). conform still wins for js/ts/json because
    -- lsp_format = 'fallback'. Needs an oxfmt root marker (package.json,
    -- .oxfmtrc.json, oxfmt.config.ts, vite.config.ts).
    "oxfmt",
    -- "rust-glancer",  -- managed by language_rust.lua
    "texlab",
    "yamlls",
}

-- superhtml only when the binary is available (configured above)
if vim.fn.executable "superhtml" == 1 then
    vim.lsp.enable "superhtml"
end
