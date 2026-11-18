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

-- crates.nvim only works on Cargo.toml; set it up the first time one opens.
vim.api.nvim_create_autocmd("BufRead", {
    group = vim.api.nvim_create_augroup("crates_lazy", { clear = true }),
    pattern = "Cargo.toml",
    once = true,
    callback = function()
        require("crates").setup {}
    end,
    desc = "Set up crates.nvim on the first Cargo.toml",
})

vim.lsp.config("rust_analyzer", {
    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
            },
            -- checkOnSave is a boolean now; the command moved to check.command
            checkOnSave = true,
            check = {
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
