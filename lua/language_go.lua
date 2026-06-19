-- =============================================================================
-- Go Language Support with ray-x/go.nvim
-- =============================================================================
-- Plugin: ray-x/go.nvim
-- Lazy load: on FileType go/gomod (project detection via filetype)
-- AI features: disabled
-- Formatter: goimports via gopls (on save)
-- Dependencies: ray-x/guihua.lua (optional, for UI components)
-- Tools: gopls, goimports, golangci-lint, gotestsum (via Mason)
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Register go.nvim (and optional guihua.lua for better UI).
-- During init processing, vim.pack.add defaults to load=false, so the plugin
-- is installed on disk and added to runtimepath but not yet configured.
vim.pack.add({
  { src = "https://github.com/ray-x/go.nvim" },
  { src = "https://github.com/ray-x/guihua.lua" }, -- optional: float term, codelens GUI
})

-- Guard: run go.setup() only once per session
local go_setup_done = false

-- Setup go.nvim with AI features disabled
local function setup_go_plugin()
  if go_setup_done then
    return
  end
  go_setup_done = true

  require('go').setup({
    go = 'go',
    goimports = 'gopls',
    gofmt = 'gopls',

    -- AI features: explicitly disabled
    ai = {
      enable = false,
    },

    -- LSP: use go.nvim's gopls configuration
    lsp_cfg = true,
    lsp_gofumpt = true,
    lsp_keymaps = true,
    lsp_codelens = true,
    lsp_document_formatting = true,
    lsp_inlay_hints = {
      enable = true,
    },
    lsp_semantic_highlights = false,

    -- Lint (golangci-lint v2)
    golangci_lint = {
      default = 'standard',
    },

    -- Test runner
    test_runner = 'go',
    verbose_tests = true,
    run_in_floaterm = false,
    test_efm = false,

    -- Debug (disabled by default; enable via dap_debug = true if needed)
    dap_debug = false,
    dap_debug_keymap = false,
    dap_debug_gui = false,
    dap_debug_vt = false,

    -- Format: gofumpt via gopls
    fillstruct = 'gopls',
    max_line_len = 0,
    tag_transform = false,
    tag_options = 'json=omitempty',

    -- Text objects handled by nvim-treesitter-textobjects externally
    textobjects = false,

    -- Snippets: using luasnip from elsewhere
    luasnip = false,

    -- Troubles: not using trouble.nvim for this
    trouble = false,

    -- Icons
    icons = { breakpoint = '🧘', currentpos = '🏃' },
  })

  -- Format on save: goimports via gopls
  local format_group = augroup('GoFormat', { clear = true })
  autocmd('BufWritePre', {
    pattern = '*.go',
    group = format_group,
    callback = function()
      pcall(require('go.format').goimports)
    end,
    desc = 'goimports on save',
  })
end

-- Lazy load: setup go.nvim when a Go file is opened.
-- The FileType gate is the project-detection mechanism — if filetype is "go",
-- we need Go tooling. No go.mod check needed since gopls handles project root
-- discovery internally.
autocmd('FileType', {
  pattern = { 'go', 'gomod', 'gosum', 'gotmpl', 'gohtmltmpl', 'gotexttmpl' },
  callback = function()
    setup_go_plugin()
  end,
  desc = 'Lazy load go.nvim on Go filetype',
})
