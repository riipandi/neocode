-- ============================================================================
-- General Keymaps: leader, escape, search, editing, windows
-- ============================================================================
local snacks = require("snacks")

-- Escape: Close floating windows or clear search
-- Skips snacks picker/input/select windows — they handle Escape themselves
vim.keymap.set({ "n", "t" }, "<Esc>", function()
    if vim.bo.buftype == "terminal" then
        vim.cmd('close')
        return
    end
    -- Let snacks picker/input/select handle their own Escape
    local ft = vim.bo.filetype or ""
    if ft:match("^snacks_picker") or ft == "snacks_input" then
        return
    end
    local conf = vim.api.nvim_win_get_config(0)
    if conf.relative ~= "" then
        vim.cmd('close')
        return
    end
    vim.cmd('nohlsearch')
end, { silent = true })

-- Search & Navigation
snacks.keymap.set("n", "<leader>sc", ":nohlsearch<CR>", { desc = "Clear search highlights" })
snacks.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
snacks.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Editing
-- `<leader>d` is reserved as the Diagnostic group (which-key + LSP), so the
-- delete-without-yank mapping lives on `<leader>D`.
snacks.keymap.set({ "n", "v" }, "<leader>D", '"_d', { desc = "Delete without yanking" })
snacks.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })
snacks.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })

-- Move lines up/down with Alt+J/K
snacks.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
snacks.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
snacks.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
snacks.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Window Management
-- NOTE: <C-S-...> / <C-A-...> combos are not transmittable by most terminals,
-- so window actions live in the <leader>w group (see which-key: "Window").
snacks.keymap.set("n", "<C-\\>", ":vsplit<CR>", { desc = "Split vertical" })
snacks.keymap.set("n", "<leader>ws", ":split<CR>", { desc = "Window: Split horizontal" })
snacks.keymap.set("n", "<leader>wv", ":vsplit<CR>", { desc = "Window: Split vertical" })
snacks.keymap.set("n", "<leader>ww", ":wincmd p<CR>", { desc = "Window: Previous window" })
snacks.keymap.set("n", "<leader>wq", ":close<CR>", { desc = "Window: Close window" })
snacks.keymap.set("n", "<leader>w+", ":vertical resize +2<CR>", { desc = "Window: Increase width" })
snacks.keymap.set("n", "<leader>w-", ":vertical resize -2<CR>", { desc = "Window: Decrease width" })
snacks.keymap.set("n", "<leader>w>", ":resize +2<CR>", { desc = "Window: Increase height" })
snacks.keymap.set("n", "<leader>w<", ":resize -2<CR>", { desc = "Window: Decrease height" })
snacks.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Window: Equalize" })

-- Config & Plugins
snacks.keymap.set("n", "<leader>,", ":e ~/.config/nvim<CR>", { desc = "Edit neovim config" })
snacks.keymap.set("n", "<leader>pu", '<cmd>lua vim.pack.update()<CR>', { desc = "Update plugins" })
snacks.keymap.set("n", "<leader>cd", '<cmd>lua vim.fn.chdir(vim.fn.expand("%:p:h"))<CR>',
    { desc = "Change working directory to current file" })

-- Go Tools
snacks.keymap.set("n", "<leader>gt", function()
    local filename = vim.fn.expand('%:t')
    local cmd = string.format('gotestsum --format=standard-verbose -- -run . -count=1 %s', vim.fn.shellescape(filename))
    require('snacks').terminal(cmd, { title = 'gotestsum' })
end, { desc = 'Run gotestsum for current file' })

snacks.keymap.set("n", "<leader>gT", function()
    require('snacks').terminal('gotestsum --format=standard-verbose -- ./...', { title = 'gotestsum all' })
end, { desc = 'Run gotestsum for all tests' })

-- Scratch Buffers
snacks.keymap.set("n", "<leader>.", function()
    Snacks.scratch()
end, { desc = "Toggle scratch buffer" })

snacks.keymap.set("n", "<leader>S", function()
    Snacks.scratch.select()
end, { desc = "Select scratch buffer" })

return M
