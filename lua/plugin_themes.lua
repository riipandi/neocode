vim.pack.add({
  { src = 'https://github.com/xiyaowong/transparent.nvim' },
}, { confirm = false })

-- ============================================================================
-- Themes
-- ============================================================================

-- Load the colorscheme here. Using atomizer (custom theme)
local atomizer = require('theme_atomizer')
atomizer.setup({ transparent = true })
atomizer.load()

-- ============================================================================
-- Transparent.nvim configuration
-- Only include groups for plugins that are actually used
-- ============================================================================
require('transparent').setup({
  extra_groups = {
    -- Standard floating windows
    "NormalFloat",
    "FloatBorder",
    "FloatTitle",

    -- Snacks (explorer, picker, notifier)
    "snacks_explorer",
    "snacks_picker_list",
    "snacks_picker_normal",
    "snacks_picker_input",
    "snacks_picker_preview",

    -- Keybinding helpers
    "WhichKeyNormal",
    "WhichKeyFloat",
    "WhichKeyFloating",

    -- Mason (LSP package manager)
    "MasonNormal",

    -- LSP
    "LspInlayHint",
  },
  exclude_groups = {
    "lualine",
    "CursorLine",
    "Visual",
    "Search",
    "IncSearch",
  }
})
