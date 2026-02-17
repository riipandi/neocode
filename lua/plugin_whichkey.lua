vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim" },
})

-- ============================================================================
-- Helps you remember your Neovim keymaps.
-- ============================================================================
require('which-key').setup({
  show_help = false,
  show_keys = false,
  preset = "helix",

  -- Keys to ignore (don't show which-key popup)
  ignored_keys = { "<C-w>", "<C-h>", "<C-j>", "<C-k>", "<C-l>" },

  -- delay between pressing a key and opening which-key (milliseconds)
  -- this setting is independent of vim.o.timeoutlen
  delay = 50,

  -- Window appearance
  win = {
    border = "rounded", -- Border style
    padding = { 1, 2 }, -- Padding inside window
    wo = {
      winblend = 0, -- Slight transparency
    },
  },

  -- Layout configuration
  layout = {
    width = { min = 20, max = 50 }, -- Window width
    height = { min = 4, max = 25 }, -- Window height
    spacing = 3, -- Spacing between columns
    align = "left", -- Text alignment
  },

  icons = {
    breadcrumb = "»", -- Symbol for breadcrumb
    separator = "➜", -- Symbol between key and description
    group = "+", -- Symbol for group indicator
    -- set icon mappings to true if you have a Nerd Font
    mappings = vim.g.have_nerd_font,
    -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
    -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
    keys = vim.g.have_nerd_font and {} or {
      Up = '<Up> ',
      Down = '<Down> ',
      Left = '<Left> ',
      Right = '<Right> ',
      C = '<C-…> ',
      M = '<M-…> ',
      D = '<D-…> ',
      S = '<S-…> ',
      CR = '<CR> ',
      Esc = '<Esc> ',
      ScrollWheelDown = '<ScrollWheelDown> ',
      ScrollWheelUp = '<ScrollWheelUp> ',
      NL = '<NL> ',
      BS = '<BS> ',
      Space = '<Space> ',
      Tab = '<Tab> ',
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
    -- Navigation groups
    { "g", group = "Goto", mode = "n" },
    { "z", group = "Fold", mode = "n" },
    { "[", group = "Prev", mode = "n" },
    { "]", group = "Next", mode = "n" },

    -- Leader groups (alphabetical)
    { '<leader>b', group = '[B]uffer', mode = "n" },
    { '<leader>c', group = '[C]ode', mode = "n" },
    { '<leader>d', group = '[D]ebug', mode = "n" },
    { '<leader>f', group = '[F]ile', mode = "n" },
    { '<leader>g', group = '[G]it', mode = "n" },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { '<leader>l', group = '[L]SP', mode = "n" },
    { '<leader>q', group = '[Q]uit', mode = "n" },
    { '<leader>s', group = '[S]earch', mode = "n" },
    { '<leader>t', group = '[T]oggle', mode = "n" },
    { '<leader>w', group = '[W]indow', mode = "n" },
    { '<leader>x', group = '[X]Trouble', mode = "n" },

    -- Visual mode groups
    { "<leader>", group = "Leader", mode = "v" },
    { "g", group = "Goto", mode = "v" },
  },

  -- Disable for certain filetypes
  disable = {
    ft = { "TelescopePrompt" },
  },
})
