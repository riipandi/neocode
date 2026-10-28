-- ============================================================================
-- Markdown Inline Rendering (render-markdown.nvim)
-- ============================================================================

vim.pack.add({
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

require("render-markdown").setup({})

-- ============================================================================
-- Keymaps
-- ============================================================================

vim.keymap.set("n", "<C-m>", "<cmd>RenderMarkdown toggle<cr>", { desc = "Markdown: Toggle inline render" })