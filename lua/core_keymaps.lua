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

-- Close other buffers (keep only current)
snacks.keymap.set("n", "<leader>bo", function()
  Snacks.bufdelete.other()
end, { desc = "Close other buffers" })

-- ============================================================================
-- Quit
-- ============================================================================

-- Quit Neocode with confirmation for unsaved changes
_G.quit_neovim = function()
  ui_select("Quit Neocode?", { "Yes", "No" }, function(choice)
    if choice ~= "Yes" then
      return
    end

    local modified_buffers = {}
    local buffers = vim.api.nvim_list_bufs()

    for _, buf in ipairs(buffers) do
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_get_option_value("modified", { buf = buf }) then
        local name = vim.api.nvim_buf_get_name(buf)
        if name ~= "" then
          table.insert(modified_buffers, { id = buf, name = vim.fs.basename(name) })
        end
      end
    end

    if #modified_buffers > 0 then
      ui_select("Unsaved buffers - save?", { "Save all and quit", "Don't save and quit", "Cancel" }, function(choice2)
        if choice2 == "Save all and quit" then
          vim.cmd("wall")
          vim.cmd("qa!")
        elseif choice2 == "Don't save and quit" then
          vim.cmd("qa!")
        end
      end)
    else
      vim.cmd("qa!")
    end
  end)
end

snacks.keymap.set("n", "<C-q>", _G.quit_neovim, { desc = "Quit Neocode" })
snacks.keymap.set("n", "<leader>qq", _G.quit_neovim, { desc = "Quit Neocode" })
snacks.keymap.set("n", "<leader>qa", ":qa<CR>", { desc = "Quit all" })
