-- ============================================================================
-- Snacks.nvim: Central Plugin Hub
-- ============================================================================

-- Replaces: nvim-tree.lua, fzf-lua, telescope (file picker now handled by fff.nvim)
-- Note: cmdline replacement handled by noice.nvim (plugin_noice.lua)

vim.pack.add({
    { src = "https://github.com/folke/snacks.nvim" },
    { src = "https://github.com/dmtrKovalenko/fff" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
    { src = "https://github.com/folke/noice.nvim" },
})

local snacks = require("snacks")
local dialog = require("dialog")

-- ============================================================================
-- Snacks Setup
-- ============================================================================

snacks.setup({
    -- File explorer (replaces nvim-tree.lua)
    explorer = {
        enabled = true,
        -- Show git status (modified/staged/untracked)
        git_status = true,
        -- Show recursive git status for open directories
        git_status_open = true,
        -- Follow symlinks
        follow = true,
    },

    -- Fuzzy picker (replaces fzf-lua/telescope; file finding replaced by fff.nvim)
    picker = {
        enabled = true,
        -- vim.ui.select is defined below; snacks would otherwise replace it as
        -- soon as the picker module loads (the explorer loads it at startup)
        ui_select = false,
        sources = {
            explorer = {
                hidden = true,
                actions = {
                    -- Enter on a file found by the search opens it. The stock confirm
                    -- only reveals the item in the tree while a search is active. The search
                    -- field is cleared afterwards, as Escape does.
                    open_result = function(picker, item, action)
                        if item and not item.dir and picker.input.filter.meta.searching then
                            Snacks.picker.actions.jump(picker, item, action)
                            -- jump defers itself when called from insert mode, so clear
                            -- the search after it ran
                            return vim.schedule(function()
                                picker.input:set("")
                                picker:find()
                            end)
                        end
                        return require("snacks.explorer.actions").actions.confirm(picker, item, action)
                    end,
                },
                win = {
                    input = { keys = { ["<CR>"] = { "open_result", mode = { "n", "i" } } } },
                    list = { keys = { ["<CR>"] = "open_result" } },
                },
                -- do not reveal the active buffer's file in the tree
                follow_file = false,
                -- sidebar preset defaults to 40 columns
                layout = { preset = "sidebar", preview = false, layout = { width = 34, min_width = 34 } },
            },
        },
        layouts = require("snacks.layouts"),
        win = {
            input = {
                keys = {
                    ["<Esc>"] = { "close", mode = { "n", "i" } },
                },
            },
            list = {
                keys = {
                    ["<Esc>"] = "close",
                },
            },
        },
    },

    -- LazyGit integration
    lazygit = {
        enabled = true,
        configure = true,
    },

    -- Notification system (replaces nvim-notify)
    notifier = {
        enabled = true,
        timeout = 4000,
        top_down = false,
        margin = { top = 0, right = 0, bottom = 0 },
    },

    -- Indentation guides (replaces indent-blankline.nvim)
    indent = {
        enabled = true,
        indent = {
            char = "│",
            hl = "SnacksIndent",
        },
        scope = {
            enabled = true,
            char = "┃",
            hl = "SnacksIndentScope",
        },
        -- Guides add noise to prose and fenced code in markdown
        filter = function(buf)
            return vim.g.snacks_indent ~= false
                and vim.b[buf].snacks_indent ~= false
                and vim.bo[buf].buftype == ""
                and vim.bo[buf].filetype ~= "markdown"
        end,
    },

    -- Scratch buffers for quick testing/notes
    scratch = {
        enabled = true,
        ft = function()
            if vim.bo.buftype == "" and vim.bo.filetype ~= "" then
                return vim.bo.filetype
            end
            return "markdown"
        end,
        autowrite = true,
    },

    -- Scope-based text objects and navigation
    scope = {
        enabled = true,
        keys = {
            textobject = {
                ii = { desc = "inner scope" },
                ai = { desc = "around scope" },
            },
            jump = {
                ["[i"] = { desc = "jump to scope top" },
                ["]i"] = { desc = "jump to scope bottom" },
            },
        },
    },

    -- Quick file rendering on startup
    quickfile = {
        enabled = true,
    },

    -- Enhanced input UI
    input = {
        enabled = true,
    },

    -- Smooth scrolling.
    -- `step` is the duration per scrolled line in ms, `total` caps the whole
    -- animation. 8ms/line made single-line scrolls finish in one frame (looked
    -- like no animation at all), while long jumps were capped at 120ms.
    scroll = {
        enabled = true,
        animate = {
            duration = { step = 45, total = 240 },
            easing = "linear",
        },
        animate_repeat = {
            -- after holding a scroll key this long, switch to the shorter
            -- profile so the view keeps up with the repeats
            delay = 130,
            duration = { step = 16, total = 90 },
            easing = "linear",
        },
        filter = function(buf)
            return vim.g.snacks_scroll ~= false and vim.b[buf].snacks_scroll ~= false and
                vim.bo[buf].buftype ~= "terminal"
        end,
    },
})

-- ============================================================================
-- Custom Window Styles
-- ============================================================================

snacks.config.styles.terminal = {
    width = 0.82,
    height = 0.82,
    border = "rounded",
    bo = {
        filetype = "snacks_terminal",
    },
    wo = {},
    keys = {
        q = "hide",
        term_normal = {
            "<esc><esc>",
            function(self)
                vim.cmd("stopinsert")
            end,
            mode = "t",
            desc = "Escape to normal mode",
        },
    },
}

-- swpui: window style lives in lua/snacks/swpui.lua (single definition)

snacks.config.styles.input = {
    backdrop = false,
    border = "rounded",
    title_pos = "center",
    height = 1,
    width = dialog.width,
    row = dialog.row,
    wo = {
        winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
        cursorline = false,
    },
    bo = {
        filetype = "snacks_input",
        buftype = "prompt",
    },
}

-- Input prompts from plugins ("Rename to: ") get the same colon-free titles.
local input = snacks.input.input
snacks.input.input = function(opts, on_confirm)
    opts = opts or {}
    if opts.prompt then
        opts = vim.tbl_extend("force", opts, { prompt = dialog.title(opts.prompt) })
    end
    return input(opts, on_confirm)
end

-- Enable smooth scrolling
snacks.scroll.enable()

-- ============================================================================
-- LazyGit Style (almost full screen, leaving space from statusline)
-- ============================================================================

snacks.config.styles.lazygit = {
    width = 0.88,
    height = 0.88,
    border = "rounded",
    bo = {
        filetype = "lazygit",
    },
    wo = {},
    keys = {
        q = "hide",
    },
}

-- ============================================================================
-- Picker Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-b>", function()
    require("core_keymaps.pin").buffers()
end, { desc = "Show buffer list" })

-- NOTE: <C-o> file finding is now handled by fff.nvim (see plugin_fff.lua)

-- ============================================================================
-- Input & Navigation Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-g>", function()
    snacks.input.input({
        prompt = "Go to [line:col]",
    }, function(input)
        if input and input ~= "" then
            local line, col = input:match("(%d+):(%d+)")
            if line and col then
                vim.cmd(line)
                vim.cmd("normal! " .. col .. "|")
            else
                local num = tonumber(input)
                if num then
                    vim.cmd(tostring(num))
                end
            end
        end
    end)
end, { desc = "Go to line or line:col" })

snacks.keymap.set("n", "<leader>;", function()
    snacks.input.input({
        prompt = "Command",
    }, function(input)
        if input and input ~= "" then
            local ok, err = pcall(vim.cmd, input)
            if not ok then
                vim.notify(tostring(err):match("E%d+:.*") or tostring(err), vim.log.levels.ERROR, { title = "Command" })
            end
        end
    end)
end, { desc = "Command palette (no auto-complete, won't close on backspace)" })

-- ============================================================================
-- Git Keymaps
-- ============================================================================

snacks.keymap.set("n", "<leader>gg", function()
    snacks.lazygit.open()
end, { desc = "Toggle LazyGit" })

-- <C-S-g> reaches Neovim in terminals that implement the kitty keyboard
-- protocol. Without a mapping it falls through to <C-g> (file info), which then
-- opens a message split.
snacks.keymap.set("n", "<C-S-g>", function()
    snacks.lazygit.open()
end, { desc = "Toggle LazyGit (Ctrl+Shift+G)" })

snacks.keymap.set("n", "<leader>gs", function()
    snacks.picker.git_status()
end, { desc = "Git status" })

-- ============================================================================
-- swpui Keymaps
-- ============================================================================

-- Global search & replace (VSCode-style)
snacks.keymap.set("n", "<leader>sr", function()
    snacks.swpui.open()
end, { desc = "Global search & replace (swpui)" })

-- <C-S-f> would otherwise fall through to <C-f> (format file).
snacks.keymap.set("n", "<C-S-f>", function()
    snacks.swpui.open()
end, { desc = "Global search & replace (Ctrl+Shift+F)" })

-- ============================================================================
-- Terminal Keymaps
-- ============================================================================

-- Floating terminal in the current working directory (the <leader>tt toggle
-- in core_keymaps/tools.lua uses the same style).
snacks.keymap.set("n", "<leader>tT", function()
    snacks.terminal.toggle(vim.o.shell, {
        cwd = vim.fn.getcwd(),
        win = { style = "terminal" },
    })
end, { desc = "Toggle floating terminal (cwd)" })

-- Override vim.ui.select with snacks picker for consistent UI.
-- The vim.ui.select contract is (items, opts, on_choice); callers rely on
-- opts.format_item, so it must be forwarded — without it snacks crashes on
-- table items ("attempt to call method 'gsub'"). Escape cancels with nil.
--
-- Focus: the cursor starts in the input (type to filter, <CR> to confirm); a
-- caller can pass `opts.focus = "list"` to start on the list instead.
vim.ui.select = function(items, opts, on_choice)
    opts = opts or {}

    if type(items) ~= "table" then
        vim.notify("Invalid items passed to vim.ui.select", vim.log.levels.ERROR)
        on_choice(nil)
        return
    end

    if type(on_choice) ~= "function" then
        on_choice = function() end
    end

    local format_item = opts.format_item
    if type(format_item) ~= "function" then
        format_item = function(item)
            if type(item) == "string" then
                return item
            end
            if type(item) == "table" then
                return item.label or item.name or item.text or vim.inspect(item):gsub("%s+", " ")
            end
            return tostring(item)
        end
    end

    local focus = opts.focus == "list" and "list" or "input"

    -- Confirmations stay narrow: as wide as the title or the longest choice
    -- ("12. " prefix, borders, scrollbar), never past the shared dialog width.
    local title = dialog.title(opts.prompt or "Select")
    local widest = vim.fn.strdisplaywidth(title) + 6
    for _, item in ipairs(items) do
        widest = math.max(widest, vim.fn.strdisplaywidth(tostring(format_item(item))) + 8)
    end
    local width = math.min(math.max(widest, 28), dialog.width + 2)
    -- Centered vertically: rows = visible choices + input + separator + borders
    local rows = math.max(math.min(#items, vim.o.lines * 0.8 - 10), 2) + 4
    local row = math.max(math.floor((vim.o.lines - rows) / 2), 0)

    local ok, err = pcall(snacks.picker.select, items, {
        prompt = title,
        format_item = function(item) return tostring(format_item(item)) end,
        snacks = {
            focus = focus,
            prompt = " ", -- one space of padding; the "" prefix is the Command Center's
            layout = { preset = "select", layout = { width = width, row = row } },
            win = { input = { keys = dialog.keys }, list = { keys = dialog.keys } },
        },
    }, function(choice)
        on_choice(choice)
    end)

    if not ok then
        vim.notify("vim.ui.select failed: " .. tostring(err), vim.log.levels.ERROR)
        on_choice(nil)
    end
end

-- ============================================================================
-- Snacks Input: Escape in normal mode
-- ============================================================================
-- snacks.input maps <Esc> only in insert mode. In normal mode the global
-- <Esc> would close the floating window without triggering the cancel
-- callback. This autocmd adds a normal-mode <Esc> that properly closes
-- the snacks input window, which fires its WinClosed handler -> callback(nil).
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("snacks_input_normal_esc", { clear = true }),
    pattern = "snacks_input",
    callback = function(ev)
        vim.keymap.set("n", "<Esc>", function()
            local win = vim.api.nvim_get_current_win()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end, { buffer = ev.buf, silent = true })
    end,
})
