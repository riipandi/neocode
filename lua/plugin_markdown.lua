-- ============================================================================
-- Markdown Preview (mdkite.nvim)
-- ============================================================================

vim.pack.add({
    { src = "https://github.com/selimacerbas/kitehost.nvim" },
    { src = "https://github.com/selimacerbas/mdkite.nvim" },
})

require("mdkite").setup({
    instance_mode = "takeover",
    port = 0,
    open_browser = true,
    default_theme = "dark",
    debounce_ms = 300,
    scroll_sync = true,
    hooks = {
        on_start = function(url)
            vim.notify("Markdown preview started", vim.log.levels.INFO)
        end,
        on_stop = function()
            vim.notify("Markdown preview stopped", vim.log.levels.INFO)
        end,
    },
})

-- ============================================================================
-- Keymaps
-- ============================================================================

vim.keymap.set("n", "<leader>mp", "<cmd>MdKite start<cr>", { desc = "Markdown: Start preview" })
vim.keymap.set("n", "<leader>mP", "<cmd>MdKite stop<cr>", { desc = "Markdown: Stop preview" })
vim.keymap.set("n", "<leader>mr", "<cmd>MdKite refresh<cr>", { desc = "Markdown: Refresh preview" })
vim.keymap.set("n", "<leader>mt", "<cmd>MdKite toggle<cr>", { desc = "Markdown: Toggle preview" })
vim.keymap.set("n", "<C-m>", "<cmd>MdKite toggle<cr>", { desc = "Markdown: Toggle preview" })