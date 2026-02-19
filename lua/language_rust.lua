-- =============================================================================
-- Rust Language Server Configuration
-- =============================================================================
-- LSP: rust-analyzer
-- Formatter: rustfmt (via conform.nvim)
-- Additional: crates.nvim for dependency management
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

vim.pack.add({
  { src = "https://github.com/saecki/crates.nvim" },
})

require('crates').setup({})

local function setup_rust_analyzer()
  local capabilities = {}
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    capabilities = blink.get_lsp_capabilities()
  end

  vim.lsp.config('rust_analyzer', {
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
          allowGlobalMutation = true,
          allowRsdocOnlyHtml = true,
          buildScripts = {
            enable = true,
          },
          features = "",
          loadOutDirsFromCheck = true,
          runBuildScripts = true,
        },
        checkOnSave = {
          allTargets = true,
          command = "clippy",
          enable = true,
          features = "",
          overrideCommand = { "cargo", "clippy", "--message-format=json" },
        },
        completion = {
          autoImport = true,
          casing = "snake_case",
          cargoFeature = {
            allFeatures = true,
          },
          snippets = "custom",
        },
        diagnostics = {
          disabled = {},
          enable = true,
          experimental = {
            enable = true,
          },
          gravity = true,
          hints = {},
        },
        files = {
          excludeDirs = { ".direnv", "node_modules", "target" },
        },
        highlightRelated = {
          closingBrackets = true,
          discriminantPulls = true,
          enumVariant = false,
          exits = true,
          forwards = true,
          references = false,
          yieldPoints = true,
        },
        hover = {
          actions = {
            enable = true,
            references = true,
            run = true,
          },
          documentation = true,
          links = true,
          memoryLayout = {
            memoryLayout = "vertical",
            prefix = "",
          },
          showColumn = true,
          showFieldsInHover = true,
        },
        inlayHints = {
          chainingHints = true,
          closingBrackets = true,
          parameterHints = true,
          typeHints = true,
        },
        lens = {
          references = {
            implementations = true,
            methodReferences = true,
            qf = true,
            run = true,
          },
          enumVariantReferences = true,
        },
        procMacro = {
          attributes = {
            enable = true,
          },
          enable = true,
          hooks = {},
        },
        runnableArgs = {},
        semanticHighlighting = {
          doc = {
            include = "always",
          },
          enums = {
            primitive = true,
          },
          fields = {
            foreground = -1,
            italic = false,
          },
          operators = {
            enable = true,
          },
          parameterHints = {
            enable = true,
          },
          pointers = {
            foreground = -1,
          },
          punctuation = {
            enable = true,
            special = {
              enable = true,
            },
          },
          references = {
            italic = false,
          },
          strings = {
            foreground = -1,
          },
        },
        typingAutoWrap = false,
      },
    },
  })

  vim.lsp.enable('rust_analyzer')
end

autocmd('FileType', {
  pattern = { 'rust' },
  callback = setup_rust_analyzer,
  desc = 'Start Rust Analyzer LSP',
})

vim.lsp.enable('rust_analyzer')
