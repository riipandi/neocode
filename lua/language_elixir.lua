-- =============================================================================
-- Elixir & Phoenix Language Server Configuration
-- =============================================================================
-- LSP: expert (official Elixir language server, https://expert-lsp.org)
--      Binary installed manually to ~/.local/bin/expert (not in Mason/Homebrew).
-- Fallback: elixirls (ElixirLS, from Mason) — kept for nvim-dap debugging,
--      which Expert does not provide yet. Used only when `expert` is absent.
-- Formatter: mix format (via conform.nvim)
-- Supports: Elixir, Phoenix, Heex, EEx templates
-- =============================================================================

local ft_pattern = { "elixir", "eelixir", "heex", "surface" }
local use_expert = vim.fn.executable "expert" == 1

if use_expert then
    -- nvim-lspconfig ships the `expert` config (cmd, filetypes, and
    -- umbrella-aware root_dir); we only widen the filetypes.
    vim.lsp.config("expert", { filetypes = ft_pattern })
    vim.lsp.enable "expert"
else
    vim.lsp.config("elixirls", {
        cmd = { "elixir-ls" },
        filetypes = ft_pattern,
        settings = {
            elixirLS = {
                dialyzerEnabled = true,
                fetchDeps = true,
                formatter = "mix format",
            },
        },
    })
    vim.lsp.enable "elixirls"
end
