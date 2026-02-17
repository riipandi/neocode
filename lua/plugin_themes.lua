vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  { src = 'https://github.com/Everblush/nvim', name = 'everblush' },
  { src = 'https://github.com/kepano/flexoki-neovim', name = 'flexoki' },
  { src = 'https://github.com/mcauley-penney/techbase.nvim' },
  { src = 'https://github.com/xiyaowong/transparent.nvim' },
}, { confirm = false })

-- ============================================================================
-- Themes
-- ============================================================================
require('catppuccin').setup({
  transparent_background = true,
  integrations = {
    aerial = true,
    alpha = true,
    cmp = true,
    dashboard = true,
    flash = true,
    grug_far = true,
    gitsigns = true,
    headlines = true,
    illuminate = true,
    indent_blankline = { enabled = true },
    leap = true,
    lsp_trouble = true,
    mason = true,
    markdown = true,
    mini = true,
    native_lsp = {
      enabled = true,
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
    },
    navic = { enabled = true, custom_bg = "lualine" },
    neotest = true,
    neotree = true,
    notify = true,
    semantic_tokens = true,
    snacks = true,
    treesitter = true,
    treesitter_context = true,
    which_key = true,
  }
})

require('flexoki').setup({
    -- @see: https://github.com/kepano/flexoki-neovim/blob/main/lua/flexoki/config.lua
	variant = 'auto',
	dark_variant = 'dark',
	light_variant = 'light',
	float_window_style = 'border',
	highlight_groups = {},
})

 -- Load the colorscheme here. List of available styles:
-- 'catppuccin-frappe' | 'catppuccin-mocha' | 'tokyonight-moon' | 'everblush' | 'flexoki-dark' | 'atomizer'
local atomizer = require('theme_atomizer')
atomizer.setup({ transparent = true })
atomizer.load()

 -- Optional, no need to run setup for this plugin.
require('transparent').setup({
  extra_groups = {
    "NormalFloat",
    "NvimTreeNormal",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "TelescopeNormal",
    "WhichKeyNormal",
    "WhichKeyFloating",
    "MasonNormal",
    "NoiceCmdlinePopup",
    "NoiceConfirm",
    "NoiceMini",
    "NotifyBackground",
    "DashboardHeader",
    "AlphaHeader",
    "LspInfoBorder",
    "BufferLineTab",
    "BufferLineTabSelected",
  },
  exclude_groups = {
      "lualine",
      "CursorLine",
      "Visual",
      "Search",
      "IncSearch",
  }
})
