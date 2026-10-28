-- ============================================================================
-- Markdown Inline Rendering (render-markdown.nvim)
-- ============================================================================

vim.pack.add({
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

require("render-markdown").setup({
    enabled = true,
    render_modes = { "n", "c", "t" },
    heading = {
        enabled = true,
    },
    code = {
        enabled = true,
        sign = true,
        style = "full",
    },
    dash = {
        enabled = true,
    },
    bullet = {
        enabled = true,
    },
    checkbox = {
        enabled = true,
    },
    quote = {
        enabled = true,
    },
    pipe_table = {
        enabled = true,
    },
    link = {
        enabled = true,
    },
    image = {
        enabled = true,
    },
    callout = {
        enabled = true,
    },
    latex = {
        enabled = true,
    },
})

-- ============================================================================
-- Keymaps
-- ============================================================================

vim.keymap.set("n", "<C-m>", "<cmd>RenderMarkdown toggle<cr>", { desc = "Markdown: Toggle inline render" })