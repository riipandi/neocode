vim.pack.add({
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
})

-- Custom lazygit floating window using telescope picker
local lazygit_win = nil

local function open_lazygit()
  -- Toggle: close if already open
  if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
    vim.api.nvim_win_close(lazygit_win, true)
    lazygit_win = nil
    return
  end

  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 4)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  lazygit_win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  vim.cmd('startinsert')

  -- Close on Escape or q
  vim.api.nvim_buf_set_keymap(buf, 't', '<esc>', '', {
    noremap = true,
    silent = true,
    callback = function()
      if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
        vim.api.nvim_win_close(lazygit_win, true)
      end
      lazygit_win = nil
    end
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', '<esc>', '', {
    noremap = true,
    silent = true,
    callback = function()
      if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
        vim.api.nvim_win_close(lazygit_win, true)
      end
      lazygit_win = nil
    end
  })
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    noremap = true,
    silent = true,
    callback = function()
      if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
        vim.api.nvim_win_close(lazygit_win, true)
      end
      lazygit_win = nil
    end
  })

  -- Run lazygit
  vim.fn.termopen('lazygit', {
    on_exit = function()
      if lazygit_win and vim.api.nvim_win_is_valid(lazygit_win) then
        vim.api.nvim_win_close(lazygit_win, true)
      end
      lazygit_win = nil
    end,
  })
end

vim.keymap.set("n", "<leader>gg", open_lazygit, { desc = "Toggle LazyGit" })
vim.keymap.set("n", "<C-S-g>", open_lazygit, { desc = "Toggle LazyGit" })

-- ============================================================================
-- Git related signs to the gutter, as well as utilities for managing changes.
-- ============================================================================
require('gitsigns').setup({
  signcolumn = false,
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'git [u]ndo stage hunk' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', gitsigns.blame_line, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle git show [b]lame line' })
    map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = '[T]oggle git show [D]eleted' })
  end,
})

-- ============================================================================
-- Powerful plugin that allows you to interact with Git from within Neovim.
-- ============================================================================
vim.keymap.set("n", "<leader>gs", '<cmd>Git<CR>', opts)
vim.keymap.set("n", "<leader>gp", '<cmd>Git push<CR>', opts)

-- -- ============================================================================
-- -- Visualise and resolve merge conflicts in Neovim
-- -- ============================================================================
-- require('git-conflict').setup({
--   -- event = { "BufReadPost", "BufWritePost", "BufNewFile" },
--   default_mappings = true, -- disable buffer local mapping created by this plugin
--   default_commands = true, -- disable commands created by this plugin
--   disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
--   list_opener = 'copen', -- command or function to open the conflicts list
--   highlights = { -- They must have background color, otherwise the default color will be used
--     incoming = 'DiffAdd',
--     current = 'DiffText',
--   }
-- })

-- ============================================================================
-- LazyGit floating window with custom highlights
-- ============================================================================

-- vim.keymap.set("n", "<leader>gf", '<cmd>LazyGitCurrentFile<CR>', { desc = "LazyGit Current File" })

-- vim.g.lazygit_floating_window_winblend = 0 -- transparency of floating window
-- vim.g.lazygit_floating_window_scaling_factor = 0.9 -- scaling factor for floating window
-- vim.g.lazygit_floating_window_border_chars = {'╭','─', '╮', '│', '╯','─', '╰', '│'} -- customize lazygit popup window border characters
-- vim.g.lazygit_floating_window_use_plenary = 0 -- use plenary.nvim to manage floating window if available
-- vim.g.lazygit_use_neovim_remote = 1 -- fallback to 0 if neovim-remote is not installed
-- vim.g.lazygit_use_custom_config_file_path = 0 -- config file path is evaluated if this value is 1
-- vim.g.lazygit_config_file_path = '' -- custom config file path
-- vim.g.lazygit_on_exit_callback = nil -- optional function callback when exiting lazygit (useful for example to refresh some UI elements after lazy git has made some changes)
