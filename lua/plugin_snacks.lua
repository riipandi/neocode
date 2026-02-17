-- Snacks.nvim - Central configuration for all Snacks modules
-- Replaces: nvim-tree.lua, fzf-lua, nvim-notify, noice.nvim, indent-blankline.nvim

vim.pack.add({
  { src = "https://github.com/folke/snacks.nvim" },
})

local snacks = require("snacks")

snacks.setup({
  -- File explorer (replaces nvim-tree.lua)
  explorer = {
    enabled = true,
    layout = {
      width = 34,
      position = "left",
    },
    filter = {
      dotfiles = true,
    },
  },

  -- Fuzzy picker (replaces fzf-lua)
  picker = {
    enabled = true,
  },

  -- Configure vim.ui.select behavior
  styles = {
    select = {
      width = 25,
      border = "rounded",
      min_height = 2,
      max_height = 8,
    },
  },

  -- LazyGit integration
  lazygit = {
    enabled = true,
    configure = true,
  },

  -- Notification system
  notifier = {
    enabled = true,
    timeout = 4000,
  },

  -- Indentation guides
  indent = {
    enabled = true,
    indent = {
      char = "│",
    },
    scope = {
      enabled = true,
      char = "┃",
    },
  },

  -- Enhanced input UI
  input = {
    enabled = true,
  },

  -- Keymap helper utilities
  keymap = {
    enabled = true,
  },

  -- Toggle utilities
  toggle = {
    enabled = true,
  },

  -- Debug utilities
  debug = {
    enabled = true,
  },

  -- Window utilities
  win = {
    enabled = true,
  },
})

-- ============================================================================
-- Navigation Keymaps
-- ============================================================================

-- Helper function to check if explorer is open
local function is_explorer_open()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match("snacks_explorer") or vim.bo[buf].filetype == "snacks_picker_list" then
      return true, win
    end
  end
  return false, nil
end

-- Helper function to check if current buffer is explorer
local function is_in_explorer()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local filetype = vim.bo.filetype
  return buf_name:match("snacks_explorer") or filetype == "snacks_picker_list"
end

-- Switch focus between explorer and editor
vim.keymap.set("n", "<C-e>", function()
  local in_explorer = is_in_explorer()
  local explorer_open, explorer_win = is_explorer_open()

  if in_explorer then
    vim.cmd("wincmd p")
  elseif explorer_open then
    vim.api.nvim_set_current_win(explorer_win)
  else
    vim.notify("File explorer is not open. Use Ctrl+Shift+E to open it.", vim.log.levels.INFO)
  end
end, { desc = "Switch focus explorer <-> editor" })

-- Toggle file explorer
vim.keymap.set("n", "<C-S-e>", function()
  snacks.explorer()
end, { desc = "Toggle file explorer" })

-- Show buffer list
vim.keymap.set("n", "<C-b>", function()
  snacks.picker.buffers({
    layout = {
      preset = "default",
    },
  })
end, { desc = "Show buffer list" })

-- Find files
vim.keymap.set("n", "<C-p>", function()
  snacks.picker.files({
    layout = {
      preset = "default",
    },
  })
end, { desc = "Find files" })

-- ============================================================================
-- Editor Keymaps
-- ============================================================================

-- Go to line with input prompt
vim.keymap.set("n", "<C-g>", function()
  snacks.input.input({
    prompt = "Go to [line:col]: ",
  }, function(input)
    if input and input ~= "" then
      local line, col = input:match("(%d+):(%d+)")
      if line and col then
        vim.cmd(line)
        vim.cmd("normal! " .. col .. "|")
      else
        local num = tonumber(input)
        if num then
          vim.cmd(tostring(num))
        end
      end
    end
  end)
end, { desc = "Go to line or line:col" })

-- ============================================================================
-- Git Keymaps
-- ============================================================================

-- Toggle LazyGit
vim.keymap.set("n", "<C-S-g>", function()
  snacks.lazygit.open()
end, { desc = "Toggle LazyGit" })

vim.keymap.set("n", "<leader>gg", function()
  snacks.lazygit.open()
end, { desc = "Toggle LazyGit" })

-- Git status picker
vim.keymap.set("n", "<leader>gs", function()
  snacks.picker.git_status()
end, { desc = "Git status" })

-- ============================================================================
-- Global Selection Function
-- ============================================================================

_G.fzf_select = function(prompt, choices, callback)
  if not choices or type(choices) ~= "table" then
    vim.notify("Invalid choices provided to fzf_select", vim.log.levels.ERROR)
    return
  end
  
  snacks.picker.select(choices, {
    prompt = prompt,
  }, function(choice)
    if choice then
      callback(choice)
    end
  end)
end
