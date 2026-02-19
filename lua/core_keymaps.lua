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
-- Search & Navigation
-- ============================================================================

snacks.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })
snacks.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
snacks.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
snacks.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = "Clear search highlights" })

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

-- Close current buffer with snacks
snacks.keymap.set("n", "<C-x>", function()
  Snacks.bufdelete()
end, { desc = "Close buffer" })

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
-- Quit
-- ============================================================================

snacks.keymap.set("n", "<C-q>", ":qa<CR>", { desc = "Quit all" })
snacks.keymap.set("n", "<leader>q", ":qa<CR>", { desc = "Quit all" })
snacks.keymap.set("n", "<leader>qq", ":qa<CR>", { desc = "Quit all" })

-- ============================================================================
-- Tools
-- ============================================================================

-- Terminal
snacks.keymap.set("n", "<leader>tt", function()
  Snacks.terminal.toggle(vim.o.shell, {
    win = { style = "terminal" },
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
