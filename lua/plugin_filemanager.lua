-- File management plugins
-- miniharp.nvim for quick file marks (integrated with snacks picker)

vim.pack.add({
  { src = 'https://github.com/vieitesss/miniharp.nvim' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
})

-- ============================================================================
-- Mini harpoon-like plugin for quick file navigation
-- ============================================================================
require('miniharp').setup({
  autoload = true,
  autosave = true,
  show_on_autoload = true,
})

vim.keymap.set('n', '<leader>ma', require('miniharp').toggle_file, { desc = 'miniharp: toggle file mark' })
vim.keymap.set('n', '<leader>mc', require('miniharp').clear,       { desc = 'miniharp: clear file mark' })
vim.keymap.set('n', '<C-l>',     require('miniharp').show_list,    { desc = 'miniharp: list marks' })
vim.keymap.set('n', '<C-n>',     require('miniharp').next,         { desc = 'miniharp: next file mark' })
vim.keymap.set('n', '<C-S-m>',   require('miniharp').prev,         { desc = 'miniharp: prev file mark' })
