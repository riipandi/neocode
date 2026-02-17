-- ============================================================================
-- File Management Plugins
-- ============================================================================

-- miniharp.nvim: Quick file marks (harpoon-like alternative)
-- Integrated with snacks picker for fast file navigation

vim.pack.add({
  { src = 'https://github.com/vieitesss/miniharp.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

local snacks = require("snacks")

-- ============================================================================
-- Mini harpoon configuration
-- ============================================================================

require('miniharp').setup({
  autoload = true,
  autosave = true,
  show_on_autoload = true,
})

-- ============================================================================
-- Keymaps
-- ============================================================================

snacks.keymap.set('n', '<leader>ma', require('miniharp').toggle_file, { desc = 'Mini harpoon: Toggle file mark' })
snacks.keymap.set('n', '<leader>mc', require('miniharp').clear, { desc = 'Mini harpoon: Clear marks' })
snacks.keymap.set('n', '<C-l>', require('miniharp').show_list, { desc = 'Mini harpoon: List marks' })
snacks.keymap.set('n', '<C-n>', require('miniharp').next, { desc = 'Mini harpoon: Next mark' })
snacks.keymap.set('n', '<C-S-m>', require('miniharp').prev, { desc = 'Mini harpoon: Previous mark' })
