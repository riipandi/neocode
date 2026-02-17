-- Treesitter and LSP plugins

vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
  { src = "https://github.com/ray-x/lsp_signature.nvim" },
  { src = "https://github.com/folke/trouble.nvim" },
  { src = "https://github.com/j-hui/fidget.nvim" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
}, { confirm = false })

-- ============================================================================
-- Configuration for Treesitter
-- ============================================================================
-- Defer treesitter setup until module is available
vim.defer_fn(function()
  local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
  if ok then
    treesitter.setup({
      ensure_installed = {
        'arduino', 'astro', 'bash', 'c', 'cpp', 'css', 'diff', 'eex', 'elixir',
        'gleam', 'go', 'heex', 'html', 'java', 'javascript', 'jsdoc', 'json',
        'json5', 'jsonc', 'lua', 'luadoc', 'luap', 'make', 'markdown_inline',
        'markdown', 'nix', 'printf', 'python', 'query', 'regex', 'rust', 'sql',
        'svelte', 'tcl', 'toml', 'tsx', 'typescript', 'typst', 'vim', 'vimdoc',
        'xml', 'yaml',
      },
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    })
  end
end, 100)

-- ============================================================================
-- Show function signature when you type
-- ============================================================================
vim.defer_fn(function()
  local ok, lsp_signature = pcall(require, 'lsp_signature')
  if ok then
    lsp_signature.setup({
      bind = true,
      handler_opts = {
        border = "rounded",
      },
    })
  end
end, 100)

-- ============================================================================
-- A pretty diagnostics, references, quickfix and location list
-- ============================================================================
vim.defer_fn(function()
  local ok, trouble = pcall(require, 'trouble')
  if ok then
    trouble.setup({
      use_diagnostic_signs = true,
      modes = {
        lsp = {
          win = { position = 'right' },
        },
      },
    })
  end
end, 100)

-- ============================================================================
-- LSP configuration
-- ============================================================================
local lsp_attach_group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_attach_group,
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- LSP keymaps using snacks picker
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    
    -- Use snacks picker for LSP operations
    map('grr', function() require('snacks').picker.lsp_references() end, '[G]oto [R]eferences')
    map('gri', function() require('snacks').picker.lsp_implementations() end, '[G]oto [I]mplementation')
    map('grd', function() require('snacks').picker.lsp_definitions() end, '[G]oto [D]efinition')
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    map('gO', function() require('snacks').picker.lsp_symbols() end, 'Open Document Symbols')
    map('gW', function() require('snacks').picker.lsp_workspace_symbols() end, 'Open Workspace Symbols')
    map('grt', function() require('snacks').picker.lsp_type_definitions() end, '[G]oto [T]ype Definition')

    local function client_supports_method(client, method, bufnr)
      if vim.fn.has 'nvim-0.11' == 1 then
        return client:supports_method(method, bufnr)
      else
        return client.supports_method(method, { bufnr = bufnr })
      end
    end

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- ============================================================================
-- LSP capabilities and server setup using vim.lsp.config (Neovim 0.11+)
-- ============================================================================
vim.defer_fn(function()
  local ok, blink = pcall(require, 'blink.cmp')
  if not ok then
    return
  end

  local capabilities = blink.get_lsp_capabilities()

  -- Configure LSP servers using vim.lsp.config (replaces lspconfig)
  vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    settings = {
      Lua = {
        completion = {
          callSnippet = 'Replace',
        },
      },
    },
  })

  -- Enable the LSP servers
  vim.lsp.enable({ 'lua_ls' })
end, 100)
