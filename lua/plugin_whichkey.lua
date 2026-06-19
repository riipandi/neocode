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

  spec = {
    -- Built-in prefix groups (helix preset)
    { "g", group = "Goto", mode = "n" },
    { "z", group = "Fold", mode = "n" },
    { "[", group = "Prev", mode = "n" },
    { "]", group = "Next", mode = "n" },

    -- Buffer
    { '<leader>b', group = 'Buffer', mode = "n" },
    { '<leader>bb', desc = 'Buffer picker', mode = "n" },
    { '<leader>bd', desc = 'Delete buffer', mode = "n" },
    { '<leader>bo', desc = 'Close others', mode = "n" },

    -- Diagnostic
    { '<leader>d', group = 'Diagnostic', mode = "n" },
    { '<leader>dl', desc = 'Set loclist', mode = "n" },
    { '<leader>nd', desc = 'Next diagnostic', mode = "n" },
    { '<leader>pd', desc = 'Previous diagnostic', mode = "n" },

    -- File
    { '<leader>f', group = 'File', mode = "n" },
    { '<leader>fc', desc = 'Search word (FFF)', mode = "n" },
    { '<leader>fm', desc = 'Format file', mode = "n" },
    { '<leader>fw', desc = 'Live grep (FFF)', mode = "n" },
    { '<leader>fz', desc = 'Fuzzy grep (FFF)', mode = "n" },

    -- Git
    { '<leader>g', group = 'Git', mode = "n" },
    { '<leader>gg', desc = 'LazyGit', mode = "n" },
    { '<leader>gp', desc = 'Push', mode = "n" },
    { '<leader>gs', desc = 'Status', mode = "n" },
    { '<leader>gt', desc = 'Go: test (file)', mode = "n" },
    { '<leader>gT', desc = 'Go: test (all)', mode = "n" },

    -- Git Hunk
    { '<leader>h', group = 'Git Hunk', mode = { 'n', 'v' } },
    { '<leader>hb', desc = 'Blame line', mode = "n" },
    { '<leader>hd', desc = 'Diff (index)', mode = "n" },
    { '<leader>hD', desc = 'Diff (commit)', mode = "n" },
    { '<leader>hp', desc = 'Preview hunk', mode = "n" },
    { '<leader>hr', desc = 'Reset hunk', mode = { 'n', 'v' } },
    { '<leader>hR', desc = 'Reset buffer', mode = "n" },
    { '<leader>hs', desc = 'Stage hunk', mode = { 'n', 'v' } },
    { '<leader>hS', desc = 'Stage buffer', mode = "n" },
    { '<leader>hu', desc = 'Undo stage hunk', mode = "n" },

    -- LSP
    { '<leader>ca', desc = 'Code action', mode = "n" },
    { '<leader>rn', desc = 'Rename', mode = "n" },

    -- Marks
    { '<leader>m', group = 'Marks', mode = "n" },
    { '<leader>ma', desc = 'Toggle file mark', mode = "n" },
    { '<leader>mc', desc = 'Clear marks', mode = "n" },

    -- Plugins
    { '<leader>p', group = 'Plugins', mode = "n" },
    { '<leader>pu', desc = 'Update plugins', mode = "n" },

    -- Quit
    { '<leader>q', group = 'Quit', mode = "n" },
    { '<leader>qq', desc = 'Quit all', mode = "n" },

    -- Search
    { '<leader>s', group = 'Search', mode = "n" },
    { '<leader>sr', desc = 'Serpl', mode = "n" },
    { '<leader>c', desc = 'Clear search', mode = "n" },

    -- Tools
    { '<leader>t', group = 'Tools', mode = "n" },
    { '<leader>tb', desc = 'Toggle blame', mode = "n" },
    { '<leader>tD', desc = 'Toggle deleted', mode = "n" },
    { '<leader>tm', desc = 'Mason: packages', mode = "n" },
    { '<leader>tM', desc = 'Mason: TUI', mode = "n" },
    { '<leader>tr', desc = 'Resource monitor', mode = "n" },
    { '<leader>tt', desc = 'Terminal', mode = "n" },

    -- Scratch
    { '<leader>.', desc = 'Toggle scratch', mode = "n" },
    { '<leader>S', desc = 'Select scratch', mode = "n" },

    -- Config
    { '<leader>,', desc = 'Edit config', mode = "n" },
    { '<leader>;', desc = 'Command palette', mode = "n" },

    -- Explorer
    { '<leader>e', desc = 'File explorer (toggle)', mode = "n" },
    { '<A-e>', desc = 'File explorer (close/focus)', mode = "n" },
    -- Visual mode
    { "<leader>", group = "Leader", mode = "v" },
    { "g", group = "Goto", mode = "v" },

    -- Global
    { '<C-S-f>', desc = 'Global Search (Serpl)', mode = "n" },
  },

  -- Disable for certain filetypes
  disable = {
    ft = { "snacks_picker_input" },
  },
})
