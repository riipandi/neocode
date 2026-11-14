-- ============================================================================
-- Noice.nvim: cmdline replacement with floating UI
-- ============================================================================
-- Replaces native cmdline with floating popup, allowing cmdheight=0
-- Also intercepts messages for toast-like notifications (undo/redo, search)

local noice = require("noice")
local dialog = require("dialog")

noice.setup({
    cmdline = {
        enabled = true,
        view = "cmdline_popup",
        opts = {
            position = {
                row = dialog.row,
                col = "50%",
            },
            size = {
                width = dialog.width,
                height = "auto",
                max_height = 10,
            },
            border = {
                style = "rounded",
                padding = { 0, 1 },
            },
            win_options = {
                winblend = 10,
                winhighlight = {
                    NormalFloat = "NormalFloat",
                    FloatBorder = "FloatBorder",
                },
            },
        },
        format = {
            cmdline = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { pattern = "^/", icon = "", lang = "regex" },
            search_up = { pattern = "^%?", icon = "", lang = "regex" },
            filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
            lua = { pattern = "^:%s*lua%s+", icon = "", lang = "lua" },
            help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        },
    },

    -- Messages: every msg_show goes to the `toast` view (a snacks toast), so
    -- they look like vim.notify toasts. `view = "messages"` would use the
    -- classic message area, which with cmdheight=0 makes noice open a split for
    -- a single line of output (e.g. after <C-g>).
    messages = {
        enabled = true,
        view = "toast",
        view_search = "toast",
        view_history = "messages",
        view_error = "toast",
        view_warn = "toast",
    },

    popupmenu = {
        enabled = true,
    },

    lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
    },

    -- Keep disabled — snacks.notifier handles vim.notify calls
    notify = {
        enabled = false,
    },

    routes = {
        -- Install chatter: one toast per source, updated in place
        {
            filter = { event = "msg_show", find = "^%[nvim%-treesitter" },
            view = "toast",
            opts = { title = "nvim-treesitter" },
        },
        {
            filter = { event = "msg_show", find = "^vim%.pack" },
            view = "toast",
            opts = { title = "vim.pack" },
        },
    },

    views = {
        -- Sits right under the cmdline popup (3 rows tall) at the same
        -- width, so the two read as one box
        cmdline_popupmenu = {
            position = { row = dialog.row + 3, col = "50%" },
            size = { width = dialog.width, height = "auto", max_height = 12 },
            -- the scrollbar track stays full height when the list shrinks to one row
            scrollbar = false,
            border = { style = "rounded", padding = { 0, 1 } },
        },
        toast = {
            view = "notify",
            title = "Message",
            replace = true,
            merge = true,
            timeout = 4000,
        },
    },

    presets = {
        bottom_search = false,
        command_palette = false,
        long_message_to_split = false,
        inc_rename = false,
        lsp_doc_border = false,
    },

    throttle = 1000 / 30,
})
