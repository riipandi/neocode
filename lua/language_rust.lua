-- =============================================================================
-- Rust Language Server Configuration
-- =============================================================================
-- LSP: rust-analyzer
-- Formatter: rustfmt (via conform.nvim)
-- Additional: crates.nvim for dependency management
-- =============================================================================

vim.pack.add {
    { src = "https://github.com/saecki/crates.nvim" },
}

require("crates").setup {}

vim.lsp.config("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
            },
            checkOnSave = {
                command = "clippy",
            },
            completion = {
                autoImport = true,
                snippets = "custom",
            },
            diagnostics = {
                enable = true,
            },
            hover = {
                actions = {
                    enable = true,
                },
                documentation = true,
                links = true,
            },
            procMacro = {
                enable = true,
            },
        },
    },
})

vim.lsp.enable "rust_analyzer"
