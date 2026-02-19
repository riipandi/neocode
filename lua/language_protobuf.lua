-- =============================================================================
-- Protobuf & gRPC Language Server Configuration
-- =============================================================================
-- LSP: buf (Buf LSP server)
-- Formatter: buf (via conform.nvim)
-- Provides: IntelliSense, diagnostics, code actions for .proto files
-- Also supports gRPC via grpcurl integration
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_protobuf_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('buf_ls', {
    cmd = { 'buf', 'lint', '--format', 'json' },
    filetypes = { 'proto' },
    root_dir = function(fname)
      return vim.fs.root_pattern('.git', 'buf.yaml', 'buf.gen.yaml', 'buf.work.yaml')(fname)
    end,
    capabilities = capabilities,
    settings = {},
  })

  vim.lsp.enable('buf_ls')
end

autocmd('FileType', {
  pattern = { 'proto' },
  callback = setup_protobuf_lsp,
  desc = 'Start Protobuf LSP (buf)',
})

vim.lsp.enable('buf_ls')
