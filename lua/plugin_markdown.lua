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
    -- Insert mode is intentionally absent: typing shows the raw markdown.
    render_modes = { "n", "c", "t", "v", "V", "\22" },
    heading = {
        enabled = true,
        -- No sign-column glyph for headings (the default `󰫎` sign repeated for
        -- every level); the overlay icons already mark the level.
        sign = false,
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
        -- No language icon in the sign column either: the preview keeps the
        -- gutter empty (heading.sign is disabled for the same reason).
        sign = false,
        style = "full",
        position = "left",
        width = "full",
        border = "thin",
        inline = true,
    },
    dash = {
        enabled = true,
        icon = "─",
        width = "full",
    },
    bullet = {
        enabled = true,
        -- Middle weight for level 1: `●` (U+25CF) fills the whole cell and reads
        -- as bold, while `•` (U+2022) is too thin. `◉` (U+25C9, fisheye) sits in
        -- between and comes from the same Unicode block as the other levels.
        icons = { "◉", "○", "◆", "◇" },
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
        -- Insert mode is intentionally absent: typing shows the raw markdown.
        render_modes = { "n", "c", "t", "v", "V", "\22" },
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
        -- No icon in front of links. The renderer draws the fallback icon
        -- (󰌹) for every link and swaps in per-site ones from `custom`
        -- (web -> 󰖟 for http, github -> 󰊤, …); on documents that already
        -- carry their own glyph next to the label this doubles up. Links keep
        -- their soft-blue colour, which is enough to recognise them.
        enabled = false,
        hyperlink = "",
    },
    win_options = {
        conceallevel = {
            -- 0 outside the rendered modes: insert mode shows the raw source,
            -- backticks and link targets included. treesitter conceals
            -- markdown_inline delimiters from conceallevel 2 upward.
            default = 0,
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
    -- Purple, taken from the theme's `@markup.raw` (the colour treesitter uses
    -- for raw/inline markup). Links stay blue via `@markup.link`, so inline code
    -- is recognisable without drawing the backticks.
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = "@markup.raw" })
    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", {
        fg = (ok and hl.fg) or nil,
        bg = "none",
        nocombine = false,
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

-- Open the link under the cursor with the system handler (`vim.ui.open`).
-- Works on [label](https://…), <https://…> autolinks and bare URLs; the URL is
-- read from the buffer, so it works with conceallevel and the renderer active.
local function link_under_cursor()
    local buf = vim.api.nvim_get_current_buf()

    local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf })
    if ok and node then
        local walk = node
        while walk do
            local kind = walk:type()
            if kind == "inline_link" or kind == "image" or kind == "uri_autolink" then
                for child in walk:iter_children() do
                    local ckind = child:type()
                    if ckind == "link_destination" or ckind == "uri_autolink" then
                        local text = vim.treesitter.get_node_text(child, buf)
                        local url = text:gsub("^<", ""):gsub(">$", ""):gsub("^%s+", ""):gsub("%s+$", "")
                        if url ~= "" then
                            return url
                        end
                    end
                end
            end
            walk = walk:parent()
        end
    end

    -- Fallback: first URL on the line, preferring ](…) destinations.
    local line = vim.api.nvim_get_current_line()
    local url = line:match("%]%(%s*<?([^%s%)>]+)>?") or line:match("(https?://[^%s%)>]+)")
    return url
end

local function open_link()
    local url = link_under_cursor()
    if not url then
        vim.notify("No link under cursor", vim.log.levels.WARN, { title = "Markdown" })
        return
    end
    local ok, err = pcall(vim.ui.open, url)
    if not ok then
        vim.notify("Cannot open link: " .. tostring(err), vim.log.levels.ERROR, { title = "Markdown" })
    end
end

vim.api.nvim_create_user_command("MarkdownOpenLink", open_link, {
    desc = "Open the link under the cursor",
})

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

-- Link opening is buffer-local to markdown (<C-CR> locally, <leader>ml always).
vim.api.nvim_create_autocmd("FileType", {
    group = md_group,
    pattern = { "markdown" },
    callback = function(ev)
        vim.keymap.set("n", "<C-CR>", open_link, {
            buffer = ev.buf,
            desc = "Markdown: open link under cursor",
        })
        vim.keymap.set("n", "<leader>ml", open_link, {
            buffer = ev.buf,
            desc = "Markdown: open link under cursor",
        })
    end,
})

-- Re-render markdown tables on terminal resize
vim.api.nvim_create_autocmd("VimResized", {
    group = md_group,
    callback = function()
        pcall(vim.cmd, "RenderMarkdown enable")
    end,
})