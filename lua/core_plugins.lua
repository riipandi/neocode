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
        layout = {
            width = 32,
            position = "left",
        },
        filter = {
            dotfiles = true,
        },
    },

    -- Fuzzy picker (replaces fzf-lua/telescope; file finding replaced by fff.nvim)
    picker = {
        enabled = true,
        layouts = {
            select = {
                hidden = { "preview" },
                layout = {
                    backdrop = false,
                    width = 0.2,
                    min_width = 20,
                    height = 0.3,
                    min_height = 4,
                    box = "vertical",
                    border = "rounded",
                    title = "{title}",
                    title_pos = "center",
                    { win = "input", height = 1,     border = "bottom" },
                    { win = "list",  border = "none" },
                },
            },
            buffers = {
                layout = {
                    box = "horizontal",
                    width = 0.7,
                    height = 0.8,
                    { win = "preview", title = "{preview}", width = 0.65, border = "rounded" },
                    {
                        box = "vertical",
                        width = 0.35,
                        border = "rounded",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "input", height = 1,     border = "bottom" },
                        { win = "list",  border = "none" },
                    },
                },
            },
            files = {
                layout = {
                    box = "horizontal",
                    width = 0.75,
                    height = 0.8,
                    { win = "preview", title = "{preview}", width = 0.60, border = "rounded" },
                    {
                        box = "vertical",
                        width = 0.40,
                        border = "rounded",
                        title = "{title} {live} {flags}",
                        title_pos = "center",
                        { win = "list",  border = "none" },
                        { win = "input", height = 1,     border = "top" },
                    },
                },
            },

            -- Command palette (list all Vim commands)
            commands = {
                layout = {
                    box = "vertical",
                    width = 0.35,
                    height = 0.55,
                    border = "rounded",
                    title = "{title}",
                    title_pos = "center",
                    { win = "input", height = 1,     border = "bottom" },
                    { win = "list",  border = "none" },
                },
            },

            -- Command history (previously executed commands)
            cmd_history = {
                layout = {
                    box = "vertical",
                    width = 0.6,
                    height = 0.5,
                    border = "rounded",
                    title = "{title}",
                    title_pos = "center",
                    { win = "input", height = 1,     border = "bottom" },
                    { win = "list",  border = "none" },
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
    width = 0.8,
    height = 0.8,
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

-- Serpl: Search & Replace TUI (90% size, like VSCode)
snacks.config.styles.serpl = {
    width = 0.9,
    height = 0.9,
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
    width = 0.92,
    height = 0.90,
    row = -3,
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
-- Serpl Keymaps
-- ============================================================================

-- Global search & replace (VSCode-style Ctrl+Shift+F)
snacks.keymap.set("n", "<C-S-f>", function()
    snacks.serpl.open()
end, { desc = "Global search & replace (Serpl)" })

-- Alternative keymap for serpl
snacks.keymap.set("n", "<leader>sr", function()
    snacks.serpl.open()
end, { desc = "Global search & replace (Serpl)" })

-- ============================================================================
-- Terminal Keymaps
-- ============================================================================

snacks.keymap.set("n", "<C-S-s>", function()
    snacks.terminal.toggle(vim.o.shell, {
        cwd = vim.fn.getcwd(),
        win = { style = "terminal" },
    })
end, { desc = "Toggle floating terminal" })

-- ============================================================================
-- Global UI Select Function
-- ============================================================================

_G.ui_select = function(prompt, choices, callback)
    if not choices or type(choices) ~= "table" then
        vim.notify("Invalid choices provided to ui_select", vim.log.levels.ERROR)
        return
    end

    snacks.picker.select(choices, {
        prompt = prompt,
        layout = { preset = "select" },
    }, function(choice)
        if choice then
            callback(choice)
        end
    end)
end
