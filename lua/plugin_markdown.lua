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
        sign = true,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
        position = "overlay",
        width = "block",
        border = false,
        -- No background band on any heading level. The defaults map
        -- backgrounds[level] to RenderMarkdownH1Bg..H6Bg, which link to
        -- DiffText / Visual / CursorColumn in this theme, so H1, H5 and H6 got
        -- a background while H2-H4 did not.
        backgrounds = {},
    },
    code = {
        enabled = true,
        sign = true,
        style = "full",
        position = "left",
        width = "full",
        border = "thin",
        inline = true,
        -- Show the delimiters again: treesitter conceals
        -- `code_span_delimiter` at conceallevel 2/3, which made inline code
        -- look exactly like a link. These render as literal backticks.
        inline_left = "`",
        inline_right = "`",
        highlight_inline_left = "NonText",
        highlight_inline_right = "NonText",
    },
    dash = {
        enabled = true,
        icon = "─",
        width = "full",
    },
    bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 1,
    },
    checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰱒 " },
    },
    quote = {
        enabled = true,
        icon = "▋",
        repeat_linebreak = false,
    },
    pipe_table = {
        enabled = true,
        render_modes = { "n", "c", "t", "i", "v", "V", "\22" },
        style = "full",
        cell = "padded",
        border = {
            "┌", "┬", "┐",
            "├", "┼", "┤",
            "└", "┴", "┘",
            "│", "─",
        },
        alignment_indicator = "━",
    },
    link = {
        enabled = true,
        image = "󰥶 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
    },
    win_options = {
        conceallevel = {
            default = 2,
            rendered = 3,
        },
    },
})

-- ============================================================================
-- Inline code: foreground only
-- ============================================================================
-- `RenderMarkdownCodeInline` links to `RenderMarkdownCode`, which paints the
-- background band used by code *blocks*. Re-link it to a foreground-only group
-- so `inline code` keeps its colour without a background chip; code blocks keep
-- their background.
local function inline_code_foreground_only()
    local ok, raw = pcall(vim.api.nvim_get_hl, 0, { name = "@markup.raw" })
    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
        fg = (ok and raw.fg) or nil,
        bg = "none",
    })
end

inline_code_foreground_only()

-- Colourscheme changes reset highlight groups; re-apply the override.
vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("markdown_inline_code", { clear = true }),
    callback = inline_code_foreground_only,
    desc = "Inline code without background",
})

-- ============================================================================
-- Keymaps
-- ============================================================================

-- NOTE: `<C-m>` is the same keycode as `<CR>` — mapping it hijacked Enter in
-- normal mode (it toggled the renderer instead of moving the cursor down).
vim.keymap.set("n", "<leader>mt", function()
    vim.cmd("RenderMarkdown toggle")
    vim.notify("Markdown render toggled", vim.log.levels.INFO)
end, { desc = "Markdown: Toggle inline render" })

-- Wrap text for markdown buffers
local md_group = vim.api.nvim_create_augroup("markdown_wrap", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = md_group,
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.breakindentopt = "list:2,shift:0"
    end,
})

-- Reduce bullet boldness (registered once at load; previously it sat inside
-- the FileType callback next to the VimResized autocmd, so both leaked a new
-- autocmd per opened markdown buffer)
vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { bold = false })

-- Re-render markdown tables on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
    group = md_group,
    callback = function()
        pcall(vim.cmd, "RenderMarkdown enable")
    end,
})