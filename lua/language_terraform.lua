-- =============================================================================
-- Terraform & HCL Language Server Configuration
-- =============================================================================
-- LSP: terraform-ls (HashiCorp Language Server)
-- Formatter: terraform fmt (via conform.nvim)
-- Supports: Terraform (.tf), HCL (.hcl)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

local function setup_terraform_lsp()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('terraform_ls', {
    cmd = { 'terraform-ls', 'serve' },
    filetypes = { 'terraform', 'hcl' },
    root_dir = function(fname)
      local patterns = { '.git', '.terraform' }
      for _, pattern in ipairs(patterns) do
        local found = vim.fn.finddir(pattern, fname .. ';')
        if found ~= '' then
          return vim.fn.fnamemodify(found, ':h')
        end
      end
      -- Check for tf files in current directory
      local tf_file = vim.fn.findfile('*.tf', fname .. ';')
      if tf_file ~= '' then
        return vim.fn.fnamemodify(tf_file, ':h')
      end
      return nil
    end,
    capabilities = capabilities,
    settings = {
      terraform = {
        lint = {
          path = 'terraform',
        },
        validate = {
          path = 'terraform',
        },
      },
    },
  })

  vim.lsp.enable('terraform_ls')
end

autocmd('FileType', {
  pattern = { 'terraform', 'hcl', 'tf', 'tfvars' },
  callback = setup_terraform_lsp,
  desc = 'Start Terraform LSP',
})

vim.lsp.enable('terraform_ls')
