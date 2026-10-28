vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
}, { confirm = false, load = true })

-- ============================================================================
-- Configuration for Rust crates management plugin
-- ============================================================================
-- You can add other tools here that you want Mason to install
-- for you, so that they are available from within Neovim.
local ensure_installed = {
    -- LSP servers
    "astro",
    "buf",
    "buf_ls",
    "cssls",
    "deno",
    "dockerls",
    "elixirls",
    "gopls",
    "html",
    "jsonls",
    "lua_ls",
    "oxlint",
    "rust_analyzer",
    "sqls",
    "superhtml",
    "tailwindcss-language-server",
    "taplo",
    "templ",
    "terraform-ls",
    "texlab",
    "ts_ls",
    "zls",
    -- Formatters / linters / tools referenced by conform, go.nvim and keymaps
    "black",
    "codelldb",
    "goimports",
    "golangci-lint",
    "gotestsum",
    "markdownlint",
    "oxfmt",
    "prettier",
    "prettierd",
    "shfmt",
    "sql-formatter",
    "stylua",
    "terraform",
    -- nvim-treesitter (main branch) compiles parsers with the tree-sitter CLI
    "tree-sitter-cli",
}

require('mason-tool-installer').setup({
    ensure_installed = ensure_installed
})

require('mason').setup({
    ui = {
        check_outdated_packages_on_open = true,
        backdrop = 60,
        width = 0.6,
        height = 0.7,
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        },
        keymaps = {
            toggle_package_expand = "<CR>",
            install_package = "i",
            update_package = "u",
            check_package_version = "c",
            update_all_packages = "U",
            check_outdated_packages = "C",
            uninstall_package = "X",
            cancel_installation = "<C-c>",
            apply_language_filter = "<C-f>",
            toggle_package_install_log = "<CR>",
            toggle_help = "g?",
        },
    }
})

require('mason-lspconfig').setup({
    -- Only servers that are not enabled explicitly in core_lsp.lua or
    -- language_*.lua. Everything else would be enabled twice.
    automatic_enable = {
        "cssls",
        "dockerls",
        "html",
        "jsonls",
    },
    automatic_installation = false,
    ensure_installed = {},
    -- No custom handlers needed; servers are configured in their respective
    -- language_*.lua files or via vim.lsp.config()/vim.lsp.enable().
    handlers = {},
})
