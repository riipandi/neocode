vim.pack.add({
  { src = "https://github.com/karb94/neoscroll.nvim" }
})

-- ============================================================================
-- Configuration for Rust crates management plugin
-- ============================================================================
require('neoscroll').setup({
  mappings = {                 -- Keys to be mapped to their corresponding default scrolling animation
    -- '<C-u>', '<C-d>',          -- half-page up/down
    -- '<C-b>', '<C-f>',          -- full-page up/down
    -- '<C-y>', '<C-e>',          -- line up/down
    -- 'zt', 'zz', 'zb',          -- cursor to top/center/bottom
  },
  hide_cursor = true,          -- Hide cursor while scrolling
  stop_eof = true,             -- Stop at <EOF> when scrolling downwards
  respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
  cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
  duration_multiplier = 1.0,   -- Global duration multiplier
  easing = 'linear',           -- Default easing function
  pre_hook = nil,              -- Function to run before the scrolling animation starts
  post_hook = nil,             -- Function to run after the scrolling animation ends
  performance_mode = false,    -- Disable "Performance Mode" on all buffers.
  ignored_events = {           -- Events ignored while scrolling
    'WinScrolled', 'CursorMoved'
  }
})

local neoscroll = require('neoscroll')
local keymap = {
  -- Scroll half page up/down with Ctrl+Shift+J and Ctrl+Shift+K
  ["<C-S-j>"]  = function() neoscroll.ctrl_d({ duration = 250 }) end;
  ["<C-S-k>"]  = function() neoscroll.ctrl_u({ duration = 250 }) end;

  -- Scroll full page up/down
  -- ["<S-Left>"]  = function() neoscroll.ctrl_b({ duration = 450 }) end;
  -- ["<S-Right>"] = function() neoscroll.ctrl_f({ duration = 450 }) end;

  -- Scroll line up/down
  ["<S-Up>"]  = function() neoscroll.scroll(-0.1, { move_cursor=false; duration = 100 }) end;
  ["<S-Down>"]  = function() neoscroll.scroll(0.1, { move_cursor=false; duration = 100 }) end;

  -- Scroll to top/bottom
  ["zt"] = function() neoscroll.zt({ half_win_duration = 250 }) end;
  ["zz"] = function() neoscroll.zz({ half_win_duration = 250 }) end;
  ["zb"] = function() neoscroll.zb({ half_win_duration = 250 }) end;
}
local modes = { 'n', 'v', 'x' }
for key, func in pairs(keymap) do
  vim.keymap.set(modes, key, func)
end
