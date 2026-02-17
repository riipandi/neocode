vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim" },
})

-- ============================================================================
-- Helps you remember your Neovim keymaps.
-- ============================================================================
require('which-key').setup({
  show_help = false,
  show_keys = true,
  preset = "helix",

  ignored_keys = { "<C-w>", "<C-h>", "<C-j>", "<C-k>", "<C-l>" },
  delay = 50,

  win = {
    border = "rounded",
    padding = { 1, 3, 1, 3 },
    wo = {
      winblend = 0,
    },
  },

  layout = {
    width = { min = 45, max = 65 },
    height = { min = 4, max = 25 },
    spacing = 5,
    align = "left",
  },

  icons = {
    breadcrumb = " ",
    separator = ": ",
    group = "+",
    mappings = false,
    keys = {
      Up = '<Up>',
      Down = '<Down>',
      Left = '<Left>',
      Right = '<Right>',
      C = '<C->',
      M = '<M->',
      D = '<D->',
      S = '<S->',
      CR = '<CR>',
      Esc = '<Esc>',
      ScrollWheelDown = '<ScrollWheelDown>',
      ScrollWheelUp = '<ScrollWheelUp>',
      NL = '<NL>',
      BS = '<BS>',
      Space = '<Space>',
      Tab = '<Tab>',
      F1 = '<F1>',
      F2 = '<F2>',
      F3 = '<F3>',
      F4 = '<F4>',
      F5 = '<F5>',
      F6 = '<F6>',
      F7 = '<F7>',
      F8 = '<F8>',
      F9 = '<F9>',
      F10 = '<F10>',
      F11 = '<F11>',
      F12 = '<F12>',
    },
  },

  -- Document existing key chains (alphabetical order with grouping)
  spec = {
    { "g", group = "Goto", mode = "n" },
    { "z", group = "Fold", mode = "n" },
    { "[", group = "Prev", mode = "n" },
    { "]", group = "Next", mode = "n" },

    { '<leader>b', group = 'Buffer', mode = "n" },
    { '<leader>c', group = 'Code', mode = "n" },
    { '<leader>d', group = 'Debug', mode = "n" },
    { '<leader>f', group = 'File', mode = "n" },
    { '<leader>g', group = 'Git', mode = "n" },
    { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
    { '<leader>l', group = 'LSP', mode = "n" },
    { '<leader>q', group = 'Quit', mode = "n" },
    { '<leader>s', group = 'Search', mode = "n" },
    { '<leader>t', group = 'Toggle', mode = "n" },
    { '<leader>w', group = 'Window', mode = "n" },
    { '<leader>x', group = 'Trouble', mode = "n" },
    { '<leader>:', group = 'Command', mode = "n" },

    { "<leader>", group = "Leader", mode = "v" },
    { "g", group = "Goto", mode = "v" },
  },

  -- Disable for certain filetypes
  disable = {
    ft = { "snacks_picker_input" },
  },
})
