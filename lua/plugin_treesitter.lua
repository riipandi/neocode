vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/folke/trouble.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
}, { confirm = false })

local snacks = require "snacks"

-- nvim-treesitter (main branch) no longer ships a `configs` module: the old
-- nvim-treesitter.configs.setup() block was wrapped in pcall and silently did
-- nothing, so parsers were never installed and indent/highlight options were
-- dead. Highlighting and indentation are provided per filetype by the plugin
-- itself; this only installs the parsers.
local parsers = {
    "astro",
    "bash",
    "css",
    "diff",
    "eex",
    "elixir",
    "go",
    "hcl",
    "heex",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "json5",
    "just",
    "lua",
    "luadoc",
    "luap",
    "markdown_inline",
    "markdown",
    "python",
    "query",
    "rust",
    "regex",
    "sql",
    "svelte",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
    "zig",
}

vim.defer_fn(function()
    local ok, ts = pcall(require, "nvim-treesitter")
    if not (ok and type(ts.install) == "function") then
        return
    end

    -- Filter against the parsers this treesitter release actually knows about
    -- (e.g. jsonc is covered by json and no longer shipped).
    local available = {}
    if type(ts.get_available) == "function" then
        for _, lang in ipairs(ts.get_available()) do
            available[lang] = true
        end
    end

    local wanted = {}
    for _, lang in ipairs(parsers) do
        if next(available) == nil or available[lang] then
            wanted[#wanted + 1] = lang
        end
    end

    -- Parsers are compiled with the tree-sitter CLI, which Mason installs on
    -- the first run; installing earlier fails once per language.
    local tries = 0
    local function install_when_ready()
        if vim.fn.executable("tree-sitter") == 1 then
            ts.install(wanted)
        elseif tries < 60 then
            tries = tries + 1
            vim.defer_fn(install_when_ready, 2000)
        end
    end
    install_when_ready()
end, 300)

-- Start treesitter highlighting for every filetype that has a parser.
-- nvim-treesitter (main branch) only installs parsers; it does NOT call
-- vim.treesitter.start() anymore, and Neovim's runtime only auto-starts
-- lua/markdown/help/query. Without this, e.g. Elixir/Heex stay unhighlighted.
-- Indentation is the same story: the plugin ships the `indents` queries but
-- indentexpr has to be pointed at it per buffer.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match) or args.match
        if not vim.treesitter.language.add(lang) then
            return
        end
        if not pcall(vim.treesitter.start, args.buf, lang) then
            return
        end
        if vim.treesitter.query.get(lang, "indents") then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
        local win = vim.fn.bufwinid(args.buf)
        if win ~= -1 then
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end,
    desc = "Start treesitter highlighting and indent when a parser is available",
})

-- ============================================================================
-- A pretty diagnostics, references, quickfix and location list
-- ============================================================================
vim.defer_fn(function()
    local ok, trouble = pcall(require, "trouble")
    if ok then
        trouble.setup {
            use_diagnostic_signs = true,
            modes = {
                lsp = {
                    win = { position = "right" },
                },
            },
        }
    end
end, 100)

-- ============================================================================
-- LSP configuration
-- ============================================================================
local lsp_attach_group =
    vim.api.nvim_create_augroup("lsp-attach", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = lsp_attach_group,
    callback = function(event)
        local map = function(keys, func, desc, mode)
            mode = mode or "n"
            snacks.keymap.set(
                mode,
                keys,
                func,
                { buffer = event.buf, desc = "LSP: " .. desc }
            )
        end

        -- LSP keymaps using snacks picker
        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map(
            "gra",
            vim.lsp.buf.code_action,
            "[G]oto Code [A]ction",
            { "n", "x" }
        )

        map("grr", function()
            require("snacks").picker.lsp_references()
        end, "[G]oto [R]eferences")
        map("gri", function()
            require("snacks").picker.lsp_implementations()
        end, "[G]oto [I]mplementation")
        map("grd", function()
            require("snacks").picker.lsp_definitions()
        end, "[G]oto [D]efinition")
        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("gO", function()
            require("snacks").picker.lsp_symbols()
        end, "Open Document Symbols")
        map("gW", function()
            require("snacks").picker.lsp_workspace_symbols()
        end, "Open Workspace Symbols")
        map("grt", function()
            require("snacks").picker.lsp_type_definitions()
        end, "[G]oto [T]ype Definition")

        local function client_supports_method(client, method, bufnr)
            if vim.fn.has "nvim-0.11" == 1 then
                return client:supports_method(method, bufnr)
            else
                return client.supports_method(method, { bufnr = bufnr })
            end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
            client
            and client_supports_method(
                client,
                vim.lsp.protocol.Methods.textDocument_documentHighlight,
                event.buf
            )
        then
            local highlight_augroup = vim.api.nvim_create_augroup(
                "lsp-document-highlight",
                { clear = false }
            )
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            -- per buffer: a shared group cleared on every attach kept only the
            -- last buffer's detach handler
            vim.api.nvim_create_autocmd("LspDetach", {
                group = highlight_augroup,
                buffer = event.buf,
                once = true,
                callback = function(event2)
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds {
                        group = highlight_augroup,
                        buffer = event2.buf,
                    }
                end,
            })
        end

        if
            client
            and client_supports_method(
                client,
                vim.lsp.protocol.Methods.textDocument_inlayHint,
                event.buf
            )
        then
            map("<leader>th", function()
                vim.lsp.inlay_hint.enable(
                    not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
                )
            end, "[T]oggle Inlay [H]ints")
        end
    end,
})
