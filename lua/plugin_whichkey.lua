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
    -- Groups
    { "g", group = "Goto", mode = "n" },
    { "z", group = "Fold", mode = "n" },
    { "[", group = "Prev", mode = "n" },
    { "]", group = "Next", mode = "n" },

    -- Buffer
    { '<leader>b', group = 'Buffer', mode = "n" },
    { '<leader>bb', desc = 'Buffer picker', mode = "n" },
    { '<leader>bd', desc = 'Delete buffer', mode = "n" },

    -- Debug
    { '<leader>d', group = 'Debug', mode = "n" },

    -- File
    { '<leader>f', group = 'File', mode = "n" },

    -- File Explorer
    { '<leader>e', desc = 'File explorer', mode = "n" },

    -- File Picker
    { '<leader><space>', desc = 'Find files', mode = "n" },

    -- Git
    { '<leader>g', group = 'Git', mode = "n" },
    { '<leader>gp', desc = 'Git push', mode = "n" },

    -- Git Hunk
    { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },

    -- LSP
    { '<leader>l', group = 'LSP', mode = "n" },
    { '<leader>la', desc = 'Code action', mode = "n" },
    { '<leader>lr', desc = 'Rename', mode = "n" },

    -- Action
    { '<leader>a', group = 'Action', mode = "n" },
    { '<leader>ac', desc = 'Clear search', mode = "n" },
    { '<leader>ad', desc = 'Change directory', mode = "n" },


    -- Tools
    { '<leader>t', group = 'Tools', mode = "n" },
    { '<leader>tt', desc = 'Terminal', mode = "n" },
    { '<leader>tg', desc = 'LazyGit', mode = "n" },
    { '<leader>tf', desc = 'Serpl', mode = "n" },
    { '<leader>tm', desc = 'Mason: manage packages', mode = "n" },
    { '<leader>tM', desc = 'Mason: TUI (tree view)', mode = "n" },

    -- Quit
    { '<leader>q', group = 'Quit', mode = "n" },

    -- Search
    { '<leader>s', group = 'Search', mode = "n" },
    { '<leader>sr', desc = 'Serpl', mode = "n" },

    -- Window
    { '<leader>w', group = 'Window', mode = "n" },

    -- Trouble
    { '<leader>x', group = 'Trouble', mode = "n" },

    -- Visual mode
    { "<leader>", group = "Leader", mode = "v" },
    { "g", group = "Goto", mode = "v" },

    -- Global keymaps
    { '<C-S-f>', desc = 'Global Search (Serpl)', mode = "n" },
  },

  -- Disable for certain filetypes
  disable = {
    ft = { "snacks_picker_input" },
  },
})
