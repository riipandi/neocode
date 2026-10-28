-- ============================================================================
-- Markdown Inline Rendering (render-markdown.nvim)
-- ============================================================================

vim.pack.add({
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

require("render-markdown").setup({
    anti_conceal = {
        enabled = false,
    },
    render_modes = { "n", "c", "t", "i", "v", "V", "\22" },
    heading = {
        enabled = true,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
    },
})

-- ============================================================================
-- Keymaps
-- ============================================================================

vim.keymap.set("n", "<C-m>", function()
    vim.cmd("RenderMarkdown toggle")
    vim.notify("Markdown render toggled", vim.log.levels.INFO)
end, { desc = "Markdown: Toggle inline render" })

-- Wrap text for markdown buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.breakindentopt = "list:2,shift:0"

-- Reduce bullet boldness
vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { bold = false })

-- Re-render markdown tables on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
        pcall(vim.cmd, "RenderMarkdown enable")
    end,
})
    end,
})