vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
  { src = "https://github.com/folke/lazydev.nvim" },
  { src = "https://github.com/xzbdmw/colorful-menu.nvim" },
})

-- ============================================================================
-- Lazydev configures Lua LSP for your Neovim config, runtime and plugins
-- used for completion, annotations and signatures of Neovim apis
-- ============================================================================
require('lazydev').setup({
  library = {
    -- Load luvit types when the `vim.uv` word is found
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
})

-- ============================================================================
-- Configuration for Rust crates management plugin
-- ============================================================================
require('blink.cmp').setup({
  keymap = {
    preset = 'default',  -- 'default' sudah simple
    ['<Left>'] = { 'select_prev' },
    ['<Right>'] = { 'select_next' },
  },

  appearance = {
    -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono',
  },

  completion = {
    -- By default, you may press `<c-space>` to show the documentation.
    -- Optionally, set `auto_show = true` to show the documentation after a delay.
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
    providers = {
      lazydev = {
        module = 'lazydev.integrations.blink',
        score_offset = 100
      },
      snippets = {
        opts = {
          friendly_snippets = true,
          -- extended_filetypes = {
          --   markdown = { 'jekyll' },
          --   sh = { 'shelldoc' },
          --   php = { 'phpdoc' },
          --   cpp = { 'unreal' }
          -- }
        },
      }
    },
  },

  -- snippets = { preset = 'luasnip' },
  fuzzy = {
    implementation = 'lua', -- 'lua' (default) or 'prefer_rust_with_warning'
    sorts = {
      'score',      -- Primary sort: by fuzzy matching score
      'sort_text',  -- Secondary sort: by sortText field if scores are equal
      'label',      -- Tertiary sort: by label if still tied
    }
  },
  signature = { enabled = true },
})

-- ============================================================================
-- Colorful-menu, bring enjoyment to your auto completion.
-- ============================================================================
require('colorful-menu').setup({
  ft = {
    lua = {
      -- Maybe you want to dim arguments a bit.
      auguments_hl = '@comment',
    },
    typescript = {
      -- Or "vtsls", their information is different, so we
      -- need to know in advance.
      ls = 'typescript-language-server',
    },
    rust = {
      -- such as (as Iterator), (use std::io).
      extra_info_hl = '@comment',
    },
    c = {
      -- such as "From <stdio.h>"
      extra_info_hl = '@comment',
    },
  },
  -- If the built-in logic fails to find a suitable highlight group,
  -- this highlight is applied to the label.
  fallback_highlight = '@variable',
  -- If provided, the plugin truncates the final displayed text to
  -- this width (measured in display cells). Any highlights that extend
  -- beyond the truncation point are ignored. Default 60.
  max_width = 60,
})
