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

local capabilities = {}
local ok, blink = pcall(require, "blink.cmp")
if ok then
    capabilities = blink.get_lsp_capabilities()
end

if use_expert then
    -- nvim-lspconfig ships the `expert` config (cmd, filetypes, and
    -- umbrella-aware root_dir); we only add capabilities here.
    vim.lsp.config("expert", {
        filetypes = ft_pattern,
        capabilities = capabilities,
    })
    vim.lsp.enable "expert"
else
    vim.lsp.config("elixirls", {
        cmd = { "elixir-ls" },
        capabilities = capabilities,
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
