-- ============================================================================
-- Splash: dimmed Neovim intro next to the explorer sidebar
-- ============================================================================
-- The built-in intro is only drawn while there is a single window, so opening
-- the sidebar kills it (and `:intro` repaints the whole screen over it). This
-- redraws the intro text as virtual lines in any empty unnamed buffer, centred
-- in the main window, and opens the explorer without taking focus.
local ns = vim.api.nvim_create_namespace("splash")
local rule = string.rep("─", 42)

local function lines()
    local v = vim.version()
    -- the `type` lines are left-aligned as one block; the rest is centred
    return {
        "│ ╲ ││",
        "││╲╲││",
        "││ ╲ │",
        "",
        ("NVIM v%d.%d.%d"):format(v.major, v.minor, v.patch),
        rule,
        "Nvim is open source and freely distributable",
        "https://neovim.io/#chat",
        rule,
        "type  :help nvim<Enter>     if you are new!",
        "type  :checkhealth<Enter>   to optimize Nvim",
        "type  :q<Enter>             to exit",
        "type  :help<Enter>          for help",
    }
end

local function is_blank(buf)
    return vim.bo[buf].buftype == "" and vim.bo[buf].filetype == "" and not vim.bo[buf].modified
        and vim.api.nvim_buf_get_name(buf) == ""
        and vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
end

local function show(win)
    local buf = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    if vim.api.nvim_win_get_config(win).relative ~= "" or not is_blank(buf) then return end

    local text = lines()
    local width = vim.api.nvim_win_get_width(win)
    -- virtual lines start after the number/sign columns; centre on the window
    local textoff = vim.fn.getwininfo(win)[1].textoff
    local block = 0
    for _, l in ipairs(text) do
        if l:find("^type ") then block = math.max(block, vim.fn.strdisplaywidth(l)) end
    end
    local pad = math.max(0, math.floor((vim.api.nvim_win_get_height(win) - #text) / 2) - 1)
    local virt = {}
    for _ = 1, pad do virt[#virt + 1] = { { "" } } end
    for _, l in ipairs(text) do
        local w = l:find("^type ") and block or vim.fn.strdisplaywidth(l)
        local left = math.max(0, math.floor((width - w) / 2) - textoff)
        virt[#virt + 1] = { { string.rep(" ", left) .. l, "NonText" } }
    end
    vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { virt_lines = virt })

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertEnter" }, {
        buffer = buf,
        once = true,
        callback = function() vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end,
    })
end

-- Every window, not just the current one: the sidebar may have focus while the
-- main window is the one that got resized.
local function refresh()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do show(win) end
end

local group = vim.api.nvim_create_augroup("splash", { clear = true })
-- BufEnter does not fire for the startup buffer, so VimEnter covers that one.
-- WinResized re-centres the text when the sidebar opens or closes; WinClosed
-- fires before the window is gone, hence the schedule.
vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "WinResized" }, { group = group, callback = refresh })
vim.api.nvim_create_autocmd("WinClosed", { group = group, callback = function() vim.schedule(refresh) end })

vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
        -- scheduled so snacks' own directory handling (nvim .) runs first.
        -- `enter = false` keeps focus in the main window; `focus = false`
        -- would make later `picker:focus()` calls land on the search input.
        vim.schedule(function()
            if #Snacks.picker.get({ source = "explorer" }) == 0 then Snacks.explorer({ enter = false }) end
            refresh()
        end)
    end,
})
