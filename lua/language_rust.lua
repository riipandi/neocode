-- =============================================================================
-- Rust Language Server Configuration
-- =============================================================================
-- LSP: rust-glancer, a release binary on PATH (~/.local/bin); the Mason
-- package points at a missing asset. Needs `rustup component add rust-src`.
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

-- Diagnostics (cargo check) are off by default. The server reads its options
-- from initializationOptions only, not from `settings`.
vim.lsp.config("rust_glancer", {
    init_options = {
        diagnostics = {
            onSave = true,
        },
    },
})

vim.lsp.enable "rust_glancer"
