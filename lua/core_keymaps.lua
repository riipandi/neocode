-- ============================================================================
-- Core Keymaps
-- ============================================================================

local snacks = require("snacks")

-- ============================================================================
-- Leader Key
-- ============================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================================
-- Escape: Close floating windows or clear search
-- ============================================================================

vim.keymap.set({ "n", "t" }, "<Esc>", function()
  -- Skip if in OpenCode terminal (let OpenCode handle Escape)
  if vim.bo.filetype == "opencode_terminal" then
    return
  end
  -- Don't close if in other terminal buffer
  if vim.bo.buftype == "terminal" then
    vim.cmd('close')
    return
  end
  -- Close floating windows
  local conf = vim.api.nvim_win_get_config(0)
  if conf.relative ~= "" then
    vim.cmd('close')
    return
  end
  -- Otherwise, clear search highlights
  vim.cmd('nohlsearch')
end, { expr = true, silent = true })

-- ============================================================================
-- Search & Navigation
-- ============================================================================

snacks.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })
snacks.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
snacks.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- ============================================================================
-- Action
-- ============================================================================

snacks.keymap.set("n", "<leader>ac", ":nohlsearch<CR>", { desc = "Clear search highlights" })
snacks.keymap.set("n", "<leader>ad", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>', { desc = "Change directory" })

-- ============================================================================
-- Editing
-- ============================================================================

snacks.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })
snacks.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
snacks.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
snacks.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines up/down with Alt+J/K
snacks.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
snacks.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
snacks.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
snacks.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ============================================================================
-- Window Management
-- ============================================================================

snacks.keymap.set("n", "<C-\\>", ":vsplit<CR>", { desc = "Split vertical" })
snacks.keymap.set("n", "<C-S-\\>", ":split<CR>", { desc = "Split horizontal" })
snacks.keymap.set("n", "<C-A-[>", ":wincmd p<CR>", { desc = "Previous window" })
snacks.keymap.set("n", "<C-A-]>", ":wincmd w<CR>", { desc = "Next window" })
snacks.keymap.set("n", "<C-A-=>", ":vertical resize +2<CR>", { desc = "Increase width" })
snacks.keymap.set("n", "<C-A-->", ":vertical resize -2<CR>", { desc = "Decrease width" })
snacks.keymap.set("n", "<C-S-=>", ":resize +2<CR>", { desc = "Increase height" })
snacks.keymap.set("n", "<C-S-->", ":resize -2<CR>", { desc = "Decrease height" })

-- ============================================================================
-- Config & Plugins
-- ============================================================================

snacks.keymap.set("n", "<leader>,", ":e ~/.config/nvim<CR>", { desc = "Edit neovim config" })
snacks.keymap.set("n", "<leader>pu", '<cmd>lua vim.pack.update()<CR>', { desc = "Update plugins" })
snacks.keymap.set("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>', { desc = "Change working directory to current file" })

-- ============================================================================
-- Go Tools
-- ============================================================================

-- Run gotestsum for current file
snacks.keymap.set("n", "<leader>gt", function()
  local filename = vim.fn.expand('%:t')
  local cmd = string.format('gotestsum --format=standard-verbose -- -run . -count=1 %s', vim.fn.shellescape(filename))
  require('snacks').terminal(cmd, { title = 'gotestsum' })
end, { desc = 'Run gotestsum for current file' })

-- Run gotestsum for all tests
snacks.keymap.set("n", "<leader>gT", function()
  require('snacks').terminal('gotestsum --format=standard-verbose -- ./...', { title = 'gotestsum all' })
end, { desc = 'Run gotestsum for all tests' })

-- ============================================================================
-- Diagnostics
-- ============================================================================

snacks.keymap.set("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({count = 1})<CR>", { desc = "Next diagnostic", silent = true })
snacks.keymap.set("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({count = -1})<CR>", { desc = "Previous diagnostic", silent = true })

-- ============================================================================
-- Scratch Buffers
-- ============================================================================

-- Toggle scratch buffer for quick testing/notes
snacks.keymap.set("n", "<leader>.", function()
  Snacks.scratch()
end, { desc = "Toggle scratch buffer" })

-- Select from existing scratch buffers
snacks.keymap.set("n", "<leader>S", function()
  Snacks.scratch.select()
end, { desc = "Select scratch buffer" })

-- ============================================================================
-- Buffer Management
-- ============================================================================

-- Close current buffer (confirm only if unsaved changes)
snacks.keymap.set("n", "<C-x>", function()
  local wins = vim.api.nvim_list_wins()

  if #wins > 1 then
    vim.cmd('close')
    return
  end

  if vim.bo.modified then
    vim.ui.select({ 'Save & Close', 'Close without saving', 'Cancel' }, {
      prompt = 'Buffer has unsaved changes:',
    }, function(choice)
      local bufnr = vim.api.nvim_get_current_buf()
      if choice == 'Save & Close' then
        vim.cmd('w')
        vim.api.nvim_buf_delete(bufnr, { force = false })
      elseif choice == 'Close without saving' then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end)
  else
    vim.api.nvim_buf_delete(0, { force = false })
  end
end, { desc = 'Close buffer or split' })

-- Close all buffers with snacks
snacks.keymap.set("n", "<C-S-w>", function()
  Snacks.bufdelete.all()
end, { desc = "Close all buffers" })

-- Delete buffer
snacks.keymap.set("n", "<leader>bd", function()
  Snacks.bufdelete()
end, { desc = "Delete buffer" })

-- Buffer picker
snacks.keymap.set("n", "<leader>bb", function()
  Snacks.picker.buffers({
    layout = { preset = "buffers" },
  })
end, { desc = "Buffer picker" })

-- Close other buffers (keep only current)
snacks.keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Close other buffers" })

-- ============================================================================
-- Quit (with smart confirmation dialog)
-- ============================================================================

local function confirm_quit()
  -- Check if any buffer has unsaved changes
  local has_unsaved = false
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].modified then
      has_unsaved = true
      break
    end
  end

  if has_unsaved then
    -- Show options: Save & Quit, Quit Without Saving, Cancel
    vim.ui.select({ 'Save & Quit', 'Quit without saving', 'Cancel' }, {
      prompt = 'You have unsaved buffers:',
    }, function(choice)
      if choice == 'Save & Quit' then
        vim.cmd('wa')
        vim.cmd('qa')
      elseif choice == 'Quit without saving' then
        vim.cmd('qa!')
      end
    end)
  else
    -- No unsaved changes: simple Yes/No
    vim.ui.select({ 'Yes', 'No' }, {
      prompt = 'Quit Neovim?',
    }, function(choice)
      if choice == 'Yes' then
        vim.cmd('qa')
      end
    end)
  end
end

snacks.keymap.set("n", "<C-q>", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<leader>q", confirm_quit, { desc = 'Quit all' })
snacks.keymap.set("n", "<leader>qq", confirm_quit, { desc = 'Quit all' })

-- ============================================================================
-- Tools
-- ============================================================================

-- Terminal
snacks.keymap.set("n", "<leader>tt", function()
  Snacks.terminal(vim.o.shell, {
    lazy = false,
  })
end, { desc = "Toggle terminal" })

-- LazyGit
snacks.keymap.set("n", "<leader>tg", function()
  Snacks.lazygit.open()
end, { desc = "Open LazyGit" })

-- Serpl (Search & Replace)
snacks.keymap.set("n", "<leader>tf", function()
  Snacks.serpl()
end, { desc = "Search & Replace" })

-- Resource Monitor (mactop on Mac, btop on Linux)
-- Install: brew install mactop (Mac) or brew install btop (cross-platform)
snacks.keymap.set("n", "<leader>tr", function()
  Snacks.terminal("mactop", {
    lazy = false,
    title = "Resource Monitor",
  })
end, { desc = "Resource monitor" })

-- File Explorer
snacks.keymap.set("n", "<leader>e", function()
  Snacks.explorer()
end, { desc = "Toggle file explorer" })

-- File Picker
snacks.keymap.set("n", "<leader><space>", function()
  Snacks.picker.files({
    layout = { preset = "files" },
  })
end, { desc = "Find files" })
