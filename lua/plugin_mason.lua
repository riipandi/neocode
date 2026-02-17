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
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  "buf_ls",
  "codelldb",
  "cssls",
  "dockerls",
  "elixirls",
  "intelephense",
  "goimports",
  "golangci-lint",
  "gopls",
  "html",
  "jsonls",
  "lua_ls",
  "markdownlint",
  "nginx-config-formatter",
  "protolint",
  "rust_analyzer",
  "superhtml",
  "shfmt",
  "sql-formatter",
  "stylua",
  "tailwindcss",
  "taplo",
  "templ",
  "terraform",
  "ts_ls",
  "uv",
})

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
    automatic_enable = {
      "buf_ls",
      "elixirls",
      "gopls",
      "html",
      "lua_ls",
      "rust_analyzer",
      "stylua",
      "taillwindcss",
      "taplo",
      "templ",
      "ts_ls",
    },
    automatic_installation = false,
    ensure_installed = {}, -- explicitly set to an empty table (installs via mason-tool-installer)
    handlers = {
      function(server_name)
        local server = servers[server_name] or {}
        -- This handles overriding only values explicitly passed
        -- by the server configuration above. Useful when disabling
        -- certain features of an LSP (for example, turning off formatting for ts_ls)
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
    },
})
