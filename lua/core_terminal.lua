local autocmd = vim.api.nvim_create_autocmd

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================

-- terminal
local terminal_state = {
  buf = nil,
  win = nil,
  is_open = false,
  job_id = nil
}

local function FloatingTerminal()
  -- If terminal is already open, close it (toggle behavior)
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
    return
  end

  -- Create buffer if it doesn't exist or is invalid
  if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
    terminal_state.buf = vim.api.nvim_create_buf(false, true)
    -- Set buffer options for terminal
    vim.api.nvim_buf_set_option(terminal_state.buf, 'bufhidden', 'hide')
  end

  -- Calculate window dimensions
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.85)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create the floating window
  terminal_state.win = vim.api.nvim_open_win(terminal_state.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
  })

  -- Set window options
  vim.api.nvim_win_set_option(terminal_state.win, 'winblend', 0)
  vim.api.nvim_win_set_option(terminal_state.win, 'number', false)
  vim.api.nvim_win_set_option(terminal_state.win, 'relativenumber', false)

  -- Start terminal if not already running
  if not terminal_state.job_id then
    terminal_state.job_id = vim.fn.termopen(os.getenv("SHELL"), {
      on_exit = function()
        terminal_state.job_id = nil
        if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
          vim.api.nvim_win_close(terminal_state.win, false)
          terminal_state.is_open = false
        end
      end,
    })
  end

  terminal_state.is_open = true
  
  -- Enter insert mode after a small delay
  vim.defer_fn(function()
    vim.cmd("startinsert!")
  end, 100)
end

-- Function to explicitly close the terminal
local function CloseFloatingTerminal()
  if terminal_state.job_id then
    vim.fn.jobstop(terminal_state.job_id)
    terminal_state.job_id = nil
  end
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
  end
end

-- Key mappings
vim.keymap.set("n", "<C-S-s>", FloatingTerminal, { noremap = true, silent = true, desc = "Toggle floating terminal (Ctrl+Shift+S)" })
vim.keymap.set("t", "<Esc>", function()
  if terminal_state.is_open and vim.api.nvim_win_is_valid(terminal_state.win) then
    vim.api.nvim_win_close(terminal_state.win, false)
    terminal_state.is_open = false
  end
end, { noremap = true, silent = true, desc = "Close floating terminal from terminal mode" })
