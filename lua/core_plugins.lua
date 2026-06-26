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
        sources = {
            explorer = {
                hidden = true,
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

    -- Keymap helper utilities
    keymap = {
        enabled = true,
    },

    -- Toggle utilities
    toggle = {
        enabled = true,
    },

    -- Buffer deletion (replaces custom buffer delete logic)
    bufdelete = {
        enabled = true,
    },

    -- Debug utilities
    debug = {
        enabled = true,
    },

    -- Window utilities
    win = {
        enabled = true,
    },

    -- Terminal
    terminal = {
        enabled = true,
    },

    -- Smooth scrolling
    scroll = {
        enabled = true,
        animate = {
            duration = { step = 10, total = 200 },
            easing = "linear",
        },
        animate_repeat = {
            delay = 100,
            duration = { step = 5, total = 50 },
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

-- swpui: Search & Replace TUI
snacks.config.styles.swpui = {
    width = 0.85,
    height = 0.85,
    border = "rounded",
    bo = {
        filetype = "snacks_terminal",
    },
    wo = {},
    keys = {
        q = "hide",
    },
}

snacks.config.styles.input = {
    backdrop = false,
    border = "rounded",
    title_pos = "center",
    height = 1,
    width = 60,
    wo = {
        winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
        cursorline = false,
    },
    bo = {
        filetype = "snacks_input",
        buftype = "prompt",
    },
}

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
-- Helper Functions
-- ============================================================================

local function is_explorer_open()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local buf_name = vim.api.nvim_buf_get_name(buf)
        if buf_name:match("snacks_explorer") or vim.bo[buf].filetype == "snacks_picker_list" then
            return true, win
        end
    end
    return false, nil
end

local function is_in_explorer()
    local buf_name = vim.api.nvim_buf_get_name(0)
    local filetype = vim.bo.filetype
    return buf_name:match("snacks_explorer") or filetype == "snacks_picker_list"
end


-- ============================================================================
-- Picker Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-b>", function()
    snacks.picker.buffers({
        layout = { preset = "buffers" },
    })
end, { desc = "Show buffer list" })

-- NOTE: <C-p> file finding is now handled by fff.nvim (see plugin_fff.lua)

-- ============================================================================
-- Input & Navigation Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-g>", function()
    local height = vim.o.lines
    local row = math.floor((height - 3) / 2)
    snacks.input.input({
        prompt = "Go to [line:col]: ",
        win = {
            row = row,
        },
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
    local height = vim.o.lines
    local row = math.floor((height - 3) / 2)
    snacks.input.input({
        prompt = "Command: ",
        win = {
            row = row,
        },
    }, function(input)
        if input and input ~= "" then
            vim.cmd(input)
        end
    end)
end, { desc = "Command palette (no auto-complete, won't close on backspace)" })

-- ============================================================================
-- Git Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-S-g>", function()
    snacks.lazygit.open()
end, { desc = "Toggle LazyGit" })

snacks.keymap.set("n", "<leader>gg", function()
    snacks.lazygit.open()
end, { desc = "Toggle LazyGit" })

snacks.keymap.set("n", "<leader>gs", function()
    snacks.picker.git_status()
end, { desc = "Git status" })

-- ============================================================================
-- swpui Keymaps
-- ============================================================================

-- Global search & replace (VSCode-style Ctrl+Shift+F)
snacks.keymap.set("n", "<C-S-f>", function()
    snacks.swpui.open()
end, { desc = "Global search & replace (swpui)" })

-- Alternative keymap for swpui
snacks.keymap.set("n", "<leader>sr", function()
    snacks.swpui.open()
end, { desc = "Global search & replace (swpui)" })

-- ============================================================================
-- Terminal Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-S-s>", function()
    snacks.terminal.toggle(vim.o.shell, {
        cwd = vim.fn.getcwd(),
        win = { style = "terminal" },
    })
end, { desc = "Toggle floating terminal" })

-- Override vim.ui.select with snacks picker for consistent UI
-- Ensures Escape properly cancels (calls callback with nil)
_G.ui_select = function(prompt, choices, callback)
    if not choices or type(choices) ~= "table" then
        vim.notify("Invalid choices provided to ui_select", vim.log.levels.ERROR)
        return
    end

    snacks.picker.select(choices, {
        prompt = prompt,
        layout = { preset = "select" },
    }, function(choice)
        -- Always call callback, even on cancel (choice=nil)
        callback(choice)
    end)
end

vim.ui.select = _G.ui_select

-- ============================================================================
-- Snacks Input: Escape in normal mode
-- ============================================================================
-- snacks.input maps <Esc> only in insert mode. In normal mode the global
-- <Esc> would close the floating window without triggering the cancel
-- callback. This autocmd adds a normal-mode <Esc> that properly closes
-- the snacks input window, which fires its WinClosed handler -> callback(nil).
vim.api.nvim_create_autocmd("FileType", {
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
