-- =============================================================================
-- Language servers that need no custom configuration
-- =============================================================================
-- Commands, filetypes and root markers come from nvim-lspconfig (lsp/*.lua);
-- capabilities from the '*' config in plugin_completion.lua. Configured once and
-- enabled once: re-running vim.lsp.enable() per FileType, or enabling before the
-- config exists, left servers without a client on the first buffer.
--
--   astro       Astro (formatter: oxfmt via conform)
--   buf_ls      Protobuf (formatter: buf via conform)
--   sqls        SQL (formatter: sql-formatter via conform)
--   tofu_ls     OpenTofu / Terraform / HCL (formatter: tofu fmt via conform)
--   zls         Zig (formatter: zigfmt via conform)
-- =============================================================================

vim.lsp.enable({ 'astro', 'buf_ls', 'sqls', 'tofu_ls', 'zls' })
